"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RestaurantModel = exports.RestaurantSchema = void 0;
var mongoose_1 = require("mongoose");
exports.RestaurantSchema = new mongoose_1.Schema({
    name: { type: String, required: true },
    address: { type: String, required: true },
    imageUrl: { type: String, required: true },
    ownerId: { type: mongoose_1.Schema.Types.ObjectId, ref: 'user', required: true }
}, {
    timestamps: true,
    toJSON: {
        virtuals: true
    },
    toObject: {
        virtuals: true
    }
});
exports.RestaurantModel = (0, mongoose_1.model)('restaurant', exports.RestaurantSchema);
