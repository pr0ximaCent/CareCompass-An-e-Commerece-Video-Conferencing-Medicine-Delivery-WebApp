import * as os from 'os';
import * as path from "path";
import * as process from "process";
import data_json from "./data.json";
import {throws} from "node:assert";
import Doctor from "./models/doctor";
import mongoose from "mongoose";
import Message from "./models/message";
import Chat from "./models/chat";
import io from 'socket.io-client';
import Product from './models/product';

const main = async () => {

    const DB = "mongodb+srv://cuet:NZkkDUPWip0uAN3K@cluster0.1xfncjc.mongodb.net/?retryWrites=true&w=majority";
    await mongoose
        .connect(DB)
        .then(() => {
            console.log("Connection Successful");
        })
        .catch((e) => {
            console.log(e);
        });
    try {
        await Product.updateMany({}, { $set: { "quantity": 1111111 } });
    } catch (e) {
        console.error(e)
    }
}
main().then(r => {
    // console.log("Done")
    process.exit()
});