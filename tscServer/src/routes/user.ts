import express from "express";

const userRouter = express.Router();
import auth from "../middlewares/auth";
import Order from "../models/order";
import Product from "../models/product";
import User from "../models/user";

userRouter.post("/api/add-to-cart", auth, async (req, res) => {
    try {
        const {id} = req.body;
        const product = await Product.findById(id);
        let user = await User.findById(req.user);
        if (!user) throw new Error("Internal Server Error");
        if (user.cart.length == 0) {
            user.cart.push({product, quantity: 1});
        } else {
            let isProductFound = false;
            for (let i = 0; i < user.cart.length; i++) {
                // @ts-ignore
                if (user.cart[i].product._id.equals(product._id)) {
                    isProductFound = true;
                }
            }

            if (isProductFound) {
                let producttt = user.cart.find((productt) =>
                    // @ts-ignore
                    productt.product._id.equals(product._id)
                );
                // @ts-ignore
                producttt.quantity += 1;
            } else {
                user.cart.push({product, quantity: 1});
            }
        }
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

userRouter.delete("/api/remove-from-cart/:id", auth, async (req, res) => {
    try {
        const {id} = req.params;
        const product = await Product.findById(id);
        let user = await User.findById(req.user);
        if (!user) throw new Error("Internal Server Error");
        for (let i = 0; i < user.cart.length; i++) {
            // @ts-ignore
            if (user.cart[i].product._id.equals(product._id)) {
                if (user.cart[i].quantity == 1) {
                    user.cart.splice(i, 1);
                } else {
                    user.cart[i].quantity -= 1;
                }
            }
        }
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

// save user address
userRouter.post("/api/save-user-address", auth, async (req, res) => {
    try {
        const {address} = req.body;
        let user = await User.findById(req.user);
        if (!user) throw new Error("Internal Server Error");
        user.address = address;
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

// order product
userRouter.post("/api/order", auth, async (req, res) => {
    try {
        const {cart, totalPrice, address} = req.body;
        let products = [];

        for (let i = 0; i < cart.length; i++) {
            let product = await Product.findById(cart[i].product._id);
            if (!product) return res.status(400).json({msg: "Some Product are not found"});
            if (product.quantity >= cart[i].quantity) {
                product.quantity -= cart[i].quantity;
                products.push({product, quantity: cart[i].quantity});
                await product.save();
            } else {
                return res
                    .status(400)
                    .json({msg: `${product.name} is out of stock!`});
            }
        }

        let user = await User.findByIdAndUpdate(req.user, {
            cart: [],
        });
        if (!user) throw new Error("Internal Server Error");

        //
        // user.cart = [];
        // user = await user.save();

        let order = new Order({
            products,
            totalPrice,
            address,
            userId: req.user,
            orderedAt: new Date().getTime(),
        });
        order = await order.save();
        res.json(order);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

userRouter.get("/api/orders/me", auth, async (req, res) => {
    try {
        const orders = await Order.find({userId: req.user});
        res.json(orders);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});
userRouter.get("/api/get_all_user", auth, async (req, res) => {
    try {
        const users = await User.find();
        return res.json(users);
    } catch (e: any) {
        return res.status(500).json({error: e.message});
    }
})
export default userRouter;
