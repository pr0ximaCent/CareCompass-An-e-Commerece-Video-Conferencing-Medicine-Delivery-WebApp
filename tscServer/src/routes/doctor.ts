import express from "express";

import auth from "../middlewares/auth";
import Chat from "../models/chat";
import Doctor from "../models/doctor";
import User, {UserType} from "../models/user";
import Appointment from "../models/appointment";
import admin from "../middlewares/admin";
import message, {MessageType} from "../models/message";
import Message from "../models/message";

const doctorRouter = express.Router();


doctorRouter.post("/doctor_api/set_user_online", auth, async (req, res) => {
    try {
        const appointment_data = await Appointment.updateMany({
            userId: req.user,
        }, {
            lastActive: Date.now()
        })
        return res.send({
            message: "You are online now",
            appointment_data: `${appointment_data.modifiedCount} appointments updated`
        })
    } catch (error: any) {
        return res.status(400).send(error.message);
    }
})




doctorRouter.post("/doctor_api/search_doctor_by_category", auth, async (req, res) => {
    const {category} = req.body;
    // if (!category) {
    //     const doctor_data = await Doctor.find()
    //     return res.send(doctor_data);
    // }
    const regex = new RegExp(category, 'i') // i for case insensitive
    const doctor_data = await Doctor.find({
        speciality: {
            $regex: regex
        }
    }).populate("userId");
    console.log(doctor_data[0]);
    return res.send(doctor_data);
})
doctorRouter.post("/doctor_api/create_doctor", admin, async (req, res) => {
    const {user_id, image_url, speciality, degree, designation, workplace, fees} = req.body;
    console.log(req.body);
    if (!user_id) return res.status(400).send("User Id is required");
    if (!image_url) return res.status(400).send("Image URL is required");
    if (!speciality) return res.status(400).send("Speciality is required");
    if (!degree) return res.status(400).send("Degree is required");
    if (!designation) return res.status(400).send("Designation is required");
    if (!workplace) return res.status(400).send("Workplace is required");
    if (!fees) return res.status(400).send("Fees is required");
    if (!Number.isInteger(fees)) return res.status(400).send("Fees should be a number");
    const user = await User.findOne({
        _id: user_id
    })
    if (!user) return res.status(400).send("User not found");

    const doctor_profile = await Doctor.create({
        userId: user_id,
        onConsultation: false,
        withPatient: "",
        waitingQueue: [],
        image_url: image_url,
        speciality: speciality,
        degree: degree,
        designation: designation,
        workplace: workplace,
        fees: fees,
        rating: 0,
    })
    user.doctor_data = doctor_profile._id;
    user.type = UserType.DOCTOR;
    await user.save();
    res.send(doctor_profile);
});
doctorRouter.post("/doctor_api/create_appointment", auth, async (req, res) => {
    const {doctor_id} = req.body;
    if (!doctor_id) return res.status(400).send("Doctor Id is required");

    const [doctor_profile, user_data] = await Promise.all([
        Doctor.findOne({
            userId: doctor_id,
        }),
        User.findOne({
            _id: req.user
        })
    ]);

    // console.log(await Doctor.findById(new Schema.ObjectId(doctor_id)));
    if (!doctor_profile) return res.status(400).send("Doctor not found");
    // return res.send(doctor_profile);
    // console.log(await Doctor.findOne({
    //     userId: doctor_id
    // }));
    if (!user_data) return res.status(400).send("User not found");
    if (doctor_profile.fees > user_data.balance) return res.status(400).send("Insufficient balance");
    const previous_appointent_data = await Appointment.findOne({
        doctorId: doctor_profile.userId.toString(),
        userId: req.user,
        isDone: false,
        shouldGetDoneWithin: {
            $gt: Date.now()
        }
    });
    if (!!previous_appointent_data) return res.status(200).json({
        message: "You already have an appointment with this doctor",
        appointment_data: previous_appointent_data
    });
    const [appointment_data, doctor_user_profile] = await Promise.all([
        Appointment.create({
            doctorId: doctor_profile.userId.toString(),
            userId: req.user,
            isDone: false,
            shouldGetDoneWithin: Date.now() + 2 * 24 * 60 * 60 * 1000,
        }),
        User.findOne({
            _id: doctor_profile.userId.toString()
        })
    ])
    if (!doctor_user_profile) return res.status(400).send("Doctor user not found");
    // @TODO: make payment according to doctor fees if user already took appointment
    user_data.balance = user_data.balance - doctor_profile.fees;
    doctor_user_profile.balance = doctor_user_profile.balance + doctor_profile.fees;
    await Promise.all([
        user_data.save(),
        doctor_user_profile.save(),
    ])

    let chat = await Chat.findOne({
            user_one: doctor_profile.userId, user_two: req.user
        }
    );
    if (!chat) {
        chat = new Chat({
            user_one: doctor_profile.userId.toString(),
            user_two: req.user,
            messages: [],
        })
        await chat.save();
    }

    const new_message = new Message({
        sender: doctor_profile.userId.toString(),
        receiver: req.user,
        data: "Appointment created",
        type: MessageType.TEXT,
        sentAt: Date.now(),
    })
    await new_message.save()
    chat.messages.push(new_message._id);
    await chat.save();
    return res.json({
        message: "Appointment created successfully",
        appointment_data: appointment_data
    });

});

export default doctorRouter;
