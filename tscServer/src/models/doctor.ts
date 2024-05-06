import mongoose, {Types} from "mongoose";
import {userSchema} from "./user";
import {messageSchema} from "./message";
import {appointmentSchema} from "./appointment";


const doctorSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // This should match the model name of your User model
        required: true,
    },
    isOnline: {
        type: Boolean,
        required: true,
        default: false,
    },
    onConsultation: {
        type: Boolean,
        required: true,
        default: false,
    },
    withPatient: {
        type: String,
        required: false,
    },
    waitingQueue: [appointmentSchema],
    image_url: {
        type: String,
        required: true,
    },
    speciality: {
        type: String,
        required: true,
    },
    degree: {
        type: String,
        required: true,
    },
    designation: {
        type: String,
        required: true,
    },
    workplace: {
        type: String,
        required: true,
    },
    fees: {
        type: Number,
        required: true,
    },
    rating: {
        type: Number,
        required: true,
    },
});

const Doctor = mongoose.model("Doctor", doctorSchema);
export default Doctor