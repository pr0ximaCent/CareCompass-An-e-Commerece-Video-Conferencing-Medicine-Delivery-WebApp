import express from "express";
import auth from "../middlewares/auth";
import Chat from "../models/chat";
import mongoose from "mongoose";
import User, {UserType} from "../models/user";
import Appointment from "../models/appointment";
import Message, {MessageType} from "../models/message";
import chat from "../models/chat";
import {serialize} from "node:v8";

const inboxRouter = express.Router();


inboxRouter.post("/telemedicine_api/set_start_consultation_request", auth, async (req, res) => {
    console.log(req.body);
    if (!req.body.chat_id) return res.status(400).send("Chat ID is required");
    console.log(req.body.start_consultation_request);
    // if (!req.body.start_consultation_request) return res.status(400).send("start_consultation_request is required");

    if (typeof req.body.start_consultation_request !== "boolean") return res.status(400).send("start_consultation_request must be boolean");
    if (req.type !== UserType.DOCTOR && Boolean(req.body.start_consultation_request)) return res.status(400).send("You are not a doctor");
    if (!mongoose.isValidObjectId(req.body.chat_id)) return res.status(400).send("Chat ID is not valid");
    console.log(req.body);

    await Chat.findByIdAndUpdate(req.body.chat_id, {
        $set: {
            start_consultation_request_by_doctor: Boolean(req.body.start_consultation_request)
        }
    }).catch(e => {
        console.log(e);
        return res.status(400).send("Chat ID is not valid");
    })
    return res.send({
        message: "start consultation request sent"
    });
})

inboxRouter.get("/telemedicine_api/inbox", auth, async (req, res) => {
    let isUserDoctor = false;
    if (req.type === UserType.DOCTOR) isUserDoctor = true;
    const chats = await Chat.find({
            $or: [
                {user_one: req.user},
                {user_two: req.user}
            ]
        }
    ).populate({
        path: "user_one",
        populate: {
            path: "doctor_data",
        }
    }).populate({
        path: "user_two",
    });

    // console.log(chats);
    let chat_data = [];
    for (let chat of chats) {
        // console.log(chat);
        let appointment = await Appointment.findOne({
            doctorId: chat.user_one._id,
            userId: chat.user_two._id,
            isDone: false,
            shouldGetDoneWithin: {$gt: Date.now()}
        })
        if (!appointment) {
            chat_data.push({
                serialNumber: -1,
                // @ts-ignore
                ...chat._doc
            });
            // chat_data.push(chat);
        } else {
            // console.log(appointment.createdAt);
            let serialNumber = await Appointment.countDocuments({
                createdAt: {
                    $lt: appointment.createdAt
                },
                doctorId: appointment.doctorId,
                userId: {
                    $ne: appointment.userId,
                },
                shouldGetDoneWithin: {
                    $gt: Date.now()
                },
                isDone: false,
            });
            chat_data.push({
                serialNumber: serialNumber,
                // @ts-ignore
                ...chat._doc
            });
        }
    }
    // console.log("chat_data", chat_data.map(d=>d.serialNumber));
    return res.send(chat_data);
});
inboxRouter.post("/telemedicine_api/send_message", auth, async (req, res) => {
    if (!req.body.receiver || !req.body.message) return res.status(400).send("Receiver and message is required");
    const {receiver, message} = req.body;
    let messageType = MessageType.TEXT;
    if (req.body.type) {
        if (req.body.type === "VIDEO") {
            messageType = MessageType.VIDEOCALL;
        } else if (req.body.type === "MEDICINE") {
            messageType = MessageType.MEDICINE;
        }
    }
    console.log(req.user, receiver);
    if (req.user === receiver) return res.status(400).send("You cannot send message to yourself");
    const [sender, receiver_data] = await Promise.all([
        User.findOne({_id: req.user}),
        User.findOne({_id: receiver})
    ])
    if (!receiver_data) return res.status(400).send("Receiver not found");
    if (!sender) return res.status(400).send("Sender not found");
    let [chat_data, appointment_data] = await Promise.all([
        Chat.findOne({
            $or: [
                {user_one: req.user, user_two: receiver},
                {user_one: receiver, user_two: req.user}
            ]
        }),
        Appointment.findOne({
            $or: [
                {doctorId: receiver, userId: req.user},
                {doctorId: req.user, userId: receiver}
            ]
            // $or: [
            //     {doctorId: receiver, userId: req.user, isDone: false, shouldGetDoneWithin: {$gt: Date.now()}},
            //     {doctorId: req.user, userId: receiver, isDone: false, shouldGetDoneWithin: {$gt: Date.now()}}
            // ]
        })
    ])
    if (!appointment_data) {
        return res.status(400).send("There is no appointment between you and receiver");
    }
    if (!chat_data) {
        return res.status(400).send("There is no chat between you and receiver");
    }
    const new_message = new Message({
        sender: req.user,
        receiver: receiver,
        type: messageType,
        sentAt: new Date(Date.now()),
        data: message
    })
    await new_message.save();
    chat_data.messages.push(new_message._id);
    await chat_data.save();
    console.log(chat_data.messages);
    return res.send(chat_data);
});
inboxRouter.post("/telemedicine_api/get_message", auth, async (req, res) => {
    let message_data;
    // console.log(req.body);
    if (!req.body.receiver) return res.status(400).send("Receiver is required");
    let serialNumber = -1;
    // console.log(req.user, req.body.receiver);
    if (!req.body.time) {
        message_data = await Message.find({
            $or: [
                {sender: req.user, receiver: req.body.receiver},
                {receiver: req.user, sender: req.body.receiver}
            ]
        })
    } else {
        const appointment_data = await Appointment.findOne({
            shouldGetDoneWithin: {
                $gt: Date.now()
            },
            isDone: false,
            doctorId: (req.type === UserType.DOCTOR ? req.user : req.body.receiver),
            userId: (req.type === UserType.DOCTOR ? req.body.receiver : req.user),
        })

        if (!!appointment_data) {
            try {
                // Use the countDocuments method to count documents with createdAt < createdAtTimestamp
                const count = await Appointment.countDocuments({
                    createdAt: {
                        $lt: appointment_data.createdAt
                    },
                    doctorId: (req.type === UserType.DOCTOR ? req.user : req.body.receiver),
                    shouldGetDoneWithin: {
                        $gt: Date.now()
                    },
                    isDone: false,
                })
                serialNumber = count - 1;
            } catch (error) {
                // Handle any potential errors, e.g., database connection issues
                console.error('Error counting appointments:', error);
                throw error; // You can choose to handle or propagate the error as needed
            }
        }
        message_data = await Message.find({
            $or: [
                {sender: req.user, receiver: req.body.receiver},
                {receiver: req.user, sender: req.body.receiver}
            ],
            sentAt: {
                $gt: Date.parse(req.body.time)
            }
        })
        // console.log(message_data);
    }
    // console.log(message_data)
    return res.send({
        serialNumber: serialNumber,
        messages: message_data
    });
})

export default inboxRouter;
