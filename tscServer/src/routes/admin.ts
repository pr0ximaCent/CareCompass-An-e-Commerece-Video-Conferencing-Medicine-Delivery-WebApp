import express from "express";

const adminRouter = express.Router();
import admin from "../middlewares/admin";
import Product from "../models/product";
import Order from "../models/order";
import User from "../models/user";
import auth from "./auth";

adminRouter.post("/admin/add_balance", auth, async (req, res) => {
    try {
        const { user_id, amount } = req.body;
        if (!user_id) throw new Error("user id is required")
        if (!amount) throw new Error("amount is required")
        if (!Number.isInteger(amount)) throw new Error("amount should be a number")
        if (amount < 0) throw new Error("amount should be positive")
        let user = await User.findById(user_id);
        if (!user) throw new Error("user not found");
        user.balance += amount;
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
})

adminRouter.post("/admin/reduct_balance", auth, async (req, res) => {
    try {
        const { user_id, amount } = req.body;
        if (!user_id) throw new Error("user id is required")
        if (!amount) throw new Error("amount is required")
        if (!Number.isInteger(amount)) throw new Error("amount should be a number")
        if (amount > 0) throw new Error("amount should be negative")
        let user = await User.findById(user_id);
        if (!user) throw new Error("user not found");
        user.balance += amount;
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
})

// Add product
adminRouter.post("/admin/add-product", admin, async (req, res) => {
    try {
        const { name, description, images, quantity, price, category } = req.body;
        let product = new Product({
            name,
            description,
            images,
            quantity,
            price,
            category,
        });
        product = await product.save();
        res.json(product);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

// Get all your products
adminRouter.get("/admin/get-products", admin, async (req, res) => {
    try {
        const products = await Product.find({});
        res.json(products);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

// Delete the product
adminRouter.post("/admin/delete-product", admin, async (req, res) => {
    try {
        const { id } = req.body;
        let product = await Product.findByIdAndDelete(id);
        res.json(product);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

adminRouter.get("/admin/get-orders", admin, async (req, res) => {
    try {
        const orders = await Order.find({});
        res.json(orders);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

adminRouter.post("/admin/change-order-status", admin, async (req, res) => {
    try {
        const { id, status } = req.body;
        let order = await Order.findById(id);
        if (!order) {
            throw new Error("Internal Server Error");
        }
        order.status = status;
        order = await order.save();
        res.json(order);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

adminRouter.get("/admin/analytics", admin, async (req, res) => {
    try {
        const orders = await Order.find({});
        if (!orders) throw new Error("Internal Server Error");
        let totalEarnings = 0;

        for (let i = 0; i < orders.length; i++) {
            for (let j = 0; j < orders[i].products.length; j++) {
                // @ts-ignore
                totalEarnings += orders[i].products[j].quantity * orders[i].products[j].product.price;
            }
        }
        // CATEGORY WISE ORDER FETCHING

        const categories = [
            "prescription_medications",
            "otc_medications",
            "health_supplements",
            "personal_care_products",
            "first_aid_supplies",
            "chronic_disease_management"
        ];
        let prescription_medicationsEarnings = await fetchCategoryWiseProduct("prescription_medications");
        let otc_medicationsEarnings = await fetchCategoryWiseProduct("otc_medications");
        let health_supplementsEarnings = await fetchCategoryWiseProduct("health_supplements");
        let personal_care_productsEarnings = await fetchCategoryWiseProduct("personal_care_products");
        let first_aid_suppliesEarnings = await fetchCategoryWiseProduct("first_aid_supplies");
        let chronic_disease_managementEarnings = await fetchCategoryWiseProduct("chronic_disease_management");


        let earnings = {
            totalEarnings,
            prescription_medicationsEarnings,
            otc_medicationsEarnings,
            health_supplementsEarnings,
            personal_care_productsEarnings,
            first_aid_suppliesEarnings,
            chronic_disease_managementEarnings
        };

        res.json(earnings);
    } catch (e: any) {
        res.status(500).json({ error: e.message });
    }
});

async function fetchCategoryWiseProduct(category: string) {
    let earnings = 0;
    let categoryOrders = await Order.find({
        "products.product.category": category,
    });

    for (let i = 0; i < categoryOrders.length; i++) {
        for (let j = 0; j < categoryOrders[i].products.length; j++) {
            earnings +=
                categoryOrders[i].products[j].quantity *
                // @ts-ignore
                categoryOrders[i].products[j].product.price;
        }
    }
    return earnings;
}

export default adminRouter;
