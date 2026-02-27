"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function () { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function () { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var express_1 = require("express");
var data_1 = require("../data");
var express_async_handler_1 = __importDefault(require("express-async-handler"));
var food_model_1 = require("../models/food.model");
var restaurant_model_1 = require("../models/restaurant.model");
var auth_mid_1 = __importDefault(require("../middlewares/auth.mid"));
var http_status_1 = require("../constants/http_status");
var router = (0, express_1.Router)();
router.get('/seed', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var foodsCount, defaultRestaurant, seededRest, foodsToSeed;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.countDocuments()];
                case 1:
                    foodsCount = _a.sent();
                    if (foodsCount > 0) {
                        res.send('Seed is already done!');
                        return [2 /*return*/];
                    }

                    // Create a default restaurant if it doesn't exist
                    return [4 /*yield*/, restaurant_model_1.RestaurantModel.findOne({ name: "SevaSync Kitchen" })];
                case 2:
                    defaultRestaurant = _a.sent();
                    if (defaultRestaurant) {
                        seededRest = defaultRestaurant;
                    } else {
                        return [4 /*yield*/, restaurant_model_1.RestaurantModel.create({
                            name: "SevaSync Kitchen",
                            address: "Default Address",
                            imageUrl: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=1000",
                            // Using a dummy object ID for owner since seed might not have one linked
                            ownerId: "000000000000000000000000"
                        })];
                    }
                case 3:
                    seededRest = _a.sent();

                    foodsToSeed = data_1.sample_foods.map(f => {
                        return { ...f, restaurantId: seededRest._id.toString() };
                    });
                    return [4 /*yield*/, food_model_1.FoodModel.create(foodsToSeed)];
                case 4:
                    _a.sent();
                    res.send('Seed Is Done!');
                    return [2 /*return*/];
            }
        });
    });
}));
router.get('/', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var foods;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.find()];
                case 1:
                    foods = _a.sent();
                    res.send(foods);
                    return [2 /*return*/];
            }
        });
    });
}));
router.get('/search/:searchTerm', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var searchRegex, foods;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    searchRegex = new RegExp(req.params.searchTerm, 'i');
                    return [4 /*yield*/, food_model_1.FoodModel.find({ name: { $regex: searchRegex } })];
                case 1:
                    foods = _a.sent();
                    res.send(foods);
                    return [2 /*return*/];
            }
        });
    });
}));
router.get('/tags', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var tags, all;
        var _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.aggregate([
                    {
                        $unwind: '$tags',
                    },
                    {
                        $group: {
                            _id: '$tags',
                            count: { $sum: 1 },
                        },
                    },
                    {
                        $project: {
                            _id: 0,
                            name: '$_id',
                            count: '$count',
                        },
                    },
                ]).sort({ count: -1 })];
                case 1:
                    tags = _b.sent();
                    _a = {
                        name: 'All'
                    };
                    return [4 /*yield*/, food_model_1.FoodModel.countDocuments()];
                case 2:
                    all = (_a.count = _b.sent(),
                        _a);
                    tags.unshift(all);
                    res.send(tags);
                    return [2 /*return*/];
            }
        });
    });
}));
router.get('/tag/:tagName', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var foods;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.find({ tags: req.params.tagName })];
                case 1:
                    foods = _a.sent();
                    res.send(foods);
                    return [2 /*return*/];
            }
        });
    });
}));
router.get('/:foodId', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var food;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.findById(req.params.foodId)];
                case 1:
                    food = _a.sent();
                    res.send(food);
                    return [2 /*return*/];
            }
        });
    });
}));

router.get('/restaurant/:restaurantId', (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var foods;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, food_model_1.FoodModel.find({ restaurantId: req.params.restaurantId })];
                case 1:
                    foods = _a.sent();
                    res.send(foods);
                    return [2 /*return*/];
            }
        });
    });
}));

router.post('/', auth_mid_1.default, (0, express_async_handler_1.default)(function (req, res) {
    return __awaiter(void 0, void 0, void 0, function () {
        var _a, name, price, tags, favorite, stars, imageUrl, origins, cookTime, myRestaurant, newFood, dbFood;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    if (!req.user.isRestaurantOwner) {
                        res.status(http_status_1.HTTP_UNAUTHORIZED).send({ message: "Only restaurant owners can create food." });
                        return [2 /*return*/];
                    }

                    return [4 /*yield*/, restaurant_model_1.RestaurantModel.findOne({ ownerId: req.user.id })];
                case 1:
                    myRestaurant = _b.sent();
                    if (!myRestaurant) {
                        res.status(http_status_1.HTTP_BAD_REQUEST).send({ message: "You must create a restaurant profile first." });
                        return [2 /*return*/];
                    }

                    _a = req.body, name = _a.name, price = _a.price, tags = _a.tags, favorite = _a.favorite, stars = _a.stars, imageUrl = _a.imageUrl, origins = _a.origins, cookTime = _a.cookTime;

                    newFood = {
                        name: name,
                        price: price,
                        tags: tags || [],
                        favorite: favorite || false,
                        stars: stars || 5, // Default for new items since they have no reviews
                        imageUrl: imageUrl,
                        origins: origins || [],
                        cookTime: cookTime,
                        restaurantId: myRestaurant.id
                    };

                    return [4 /*yield*/, food_model_1.FoodModel.create(newFood)];
                case 2:
                    dbFood = _b.sent();
                    res.send(dbFood);
                    return [2 /*return*/];
            }
        });
    });
}));
exports.default = router;
