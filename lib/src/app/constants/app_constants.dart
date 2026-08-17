class UnitConversions {
  //Unit conversions
  final Map<String, Map<String, double>> unitDatabase = {
    // ========== WEIGHT/MASS ==========
    'kg': {
      'kg': 1,
      'gram': 1000,
      'milligram': 1000000,
      'pound': 2.20462,
      'ounce': 35.274,
      'ton': 0.001,
      'tonne': 0.001,
      'stone': 0.157473,
      'carat': 5000,
    },
    'kilogram': {
      'kg': 1,
      'gram': 1000,
      'milligram': 1000000,
      'pound': 2.20462,
      'ounce': 35.274,
      'ton': 0.001,
      'tonne': 0.001,
      'stone': 0.157473,
      'carat': 5000,
    },
    'kilograms': {
      'kg': 1,
      'gram': 1000,
      'milligram': 1000000,
      'pound': 2.20462,
      'ounce': 35.274,
      'ton': 0.001,
      'tonne': 0.001,
      'stone': 0.157473,
      'carat': 5000,
    },
    'كج': {
      'كج': 1,
      'غرام': 1000,
      'مل غرام': 1000000,
      'باوند': 2.20462,
      'اونس': 35.274,
      'طن': 0.001,
      'حجر': 0.157473,
      'قيراط': 5000,
    },
    'kgs': {
      'kg': 1,
      'gram': 1000,
      'milligram': 1000000,
      'pound': 2.20462,
      'ounce': 35.274,
      'ton': 0.001,
      'tonne': 0.001,
      'stone': 0.157473,
      'carat': 5000,
    },
    'كيلو': {
      'كيلو': 1,
      'غرام': 1000,
      'مل غرام': 1000000,
      'باوند': 2.20462,
      'اونس': 35.274,
      'طن': 0.001,
      'حجر': 0.157473,
      'قيراط': 5000,
    },
    'كيلو غرام': {
      'كيلو': 1,
      'غرام': 1000,
      'مل غرام': 1000000,
      'باوند': 2.20462,
      'اونس': 35.274,
      'طن': 0.001,
      'حجر': 0.157473,
      'قيراط': 5000,
    },
    'gram': {
      'gram': 1,
      'kg': 0.001,
      'milligram': 1000,
      'pound': 0.00220462,
      'ounce': 0.035274,
    },
    'g': {
      'gram': 1,
      'kg': 0.001,
      'milligram': 1000,
      'pound': 0.00220462,
      'ounce': 0.035274,
    },
    'غرام': {
      'غرام': 1,
      'كج': 0.001,
      'مل غرام': 1000,
      'باوند': 0.00220462,
      'اونس': 0.035274,
    },
    'grams': {
      'gram': 1,
      'kg': 0.001,
      'milligram': 1000,
      'pound': 0.00220462,
      'ounce': 0.035274,
    },
    'جرام': {
      'جرام': 1,
      'كج': 0.001,
      'مل غرام': 1000,
      'باوند': 0.00220462,
      'اونس': 0.035274,
    },
    'p': {
      'pound': 1,
      'kg': 0.453592,
      'gram': 453.592,
      'ounce': 16,
      'stone': 0.0714286,
    },
    'pound': {
      'pound': 1,
      'kg': 0.453592,
      'gram': 453.592,
      'ounce': 16,
      'stone': 0.0714286,
    },
    'باوند': {
      'باوند': 1,
      'كج': 0.453592,
      'غرام': 453.592,
      'اونس': 16,
      'حجر': 0.0714286,
    },
    'pounds': {
      'pound': 1,
      'kg': 0.453592,
      'gram': 453.592,
      'ounce': 16,
      'stone': 0.0714286,
    },
    'oz': {
      'ounce': 1,
      'gram': 28.3495,
      'kg': 0.0283495,
      'pound': 0.0625,
      'milligram': 28349.5,
    },
    'ounce': {
      'ounce': 1,
      'gram': 28.3495,
      'kg': 0.0283495,
      'pound': 0.0625,
      'milligram': 28349.5,
    },
    'رطل': {
      'رطل': 1,
      'كج': 0.453592,
      'غرام': 453.592,
      'اونس': 16,
      'حجر': 0.0714286,
    },
    'ounces': {
      'ounce': 1,
      'gram': 28.3495,
      'kg': 0.0283495,
      'pound': 0.0625,
      'milligram': 28349.5,
    },
    'اونس': {
      'اونس': 1,
      'غرام': 28.3495,
      'كج': 0.0283495,
      'باوند': 0.0625,
      'مل غرام': 28349.5,
    },
    'أوقية': {
      'أوقية': 1,
      'غرام': 28.3495,
      'كج': 0.0283495,
      'باوند': 0.0625,
      'مل غرام': 28349.5,
    },

    // ========== VOLUME ==========
    'liter': {
      'liter': 1,
      'milliliter': 1000,
      'gallon': 0.264172,
      'quart': 1.05669,
      'pint': 2.11338,
      'cup': 4.22675,
      'fluid ounce': 33.814,
      'tablespoon': 67.628,
      'teaspoon': 202.884,
      'cubic meter': 0.001,
      'cubic centimeter': 1000,
    },
    'ltr': {
      'liter': 1,
      'milliliter': 1000,
      'gallon': 0.264172,
      'quart': 1.05669,
      'pint': 2.11338,
      'cup': 4.22675,
      'fluid ounce': 33.814,
      'tablespoon': 67.628,
      'teaspoon': 202.884,
      'cubic meter': 0.001,
      'cubic centimeter': 1000,
    },
    'ltrs': {
      'liter': 1,
      'milliliter': 1000,
      'gallon': 0.264172,
      'quart': 1.05669,
      'pint': 2.11338,
      'cup': 4.22675,
      'fluid ounce': 33.814,
      'tablespoon': 67.628,
      'teaspoon': 202.884,
      'cubic meter': 0.001,
      'cubic centimeter': 1000,
    },
    'لتر': {
      'لتر': 1,
      'مل لتر': 1000,
      'غالون': 0.264172,
      'كوارت': 1.05669,
      'باينت': 2.11338,
      'كوب': 4.22675,
      'اونس سائل': 33.814,
      'ملعقة طعام': 67.628,
      'ملعقة شاي': 202.884,
      'متر مكعب': 0.001,
      'سم مكعب': 1000,
    },
    'liters': {
      'liter': 1,
      'milliliter': 1000,
      'gallon': 0.264172,
      'quart': 1.05669,
      'pint': 2.11338,
      'cup': 4.22675,
      'fluid ounce': 33.814,
      'tablespoon': 67.628,
      'teaspoon': 202.884,
      'cubic meter': 0.001,
      'cubic centimeter': 1000,
    },
    'لترات': {
      'لتر': 1,
      'مل لتر': 1000,
      'غالون': 0.264172,
      'كوارت': 1.05669,
      'باينت': 2.11338,
      'كوب': 4.22675,
      'اونس سائل': 33.814,
      'ملعقة طعام': 67.628,
      'ملعقة شاي': 202.884,
      'متر مكعب': 0.001,
      'سم مكعب': 1000,
    },
    'ml': {
      'milliliter': 1,
      'liter': 0.001,
      'teaspoon': 0.202884,
      'tablespoon': 0.067628,
      'fluid ounce': 0.033814,
    },
    'milliliter': {
      'milliliter': 1,
      'liter': 0.001,
      'teaspoon': 0.202884,
      'tablespoon': 0.067628,
      'fluid ounce': 0.033814,
    },
    'مل لتر': {
      'مل لتر': 1,
      'لتر': 0.001,
      'ملعقة شاي': 0.202884,
      'ملعقة طعام': 0.067628,
      'اونس سائل': 0.033814,
    },
    'milliliters': {
      'milliliter': 1,
      'liter': 0.001,
      'teaspoon': 0.202884,
      'tablespoon': 0.067628,
      'fluid ounce': 0.033814,
    },
    'مليلتر': {
      'مليلتر': 1,
      'لتر': 0.001,
      'ملعقة شاي': 0.202884,
      'ملعقة طعام': 0.067628,
      'اونس سائل': 0.033814,
    },
    'gallon': {
      'gallon': 1,
      'liter': 3.78541,
      'quart': 4,
      'pint': 8,
      'cup': 16,
      'fluid ounce': 128,
    },
    'غالون': {
      'غالون': 1,
      'لتر': 3.78541,
      'كوارت': 4,
      'باينت': 8,
      'كوب': 16,
      'اونس سائل': 128,
    },
    'gallons': {
      'gallon': 1,
      'liter': 3.78541,
      'quart': 4,
      'pint': 8,
      'cup': 16,
      'fluid ounce': 128,
    },
    'غالونات': {
      'غالون': 1,
      'لتر': 3.78541,
      'كوارت': 4,
      'باينت': 8,
      'كوب': 16,
      'اونس سائل': 128,
    },
    'cup': {
      'cup': 1,
      'ml': 236.588,
      'liter': 0.236588,
      'tablespoon': 16,
      'teaspoon': 48,
      'fluid ounce': 8,
    },
    'كوب': {
      'كوب': 1,
      'مل لتر': 236.588,
      'لتر': 0.236588,
      'ملعقة طعام': 16,
      'ملعقة شاي': 48,
      'اونس سائل': 8,
    },
    'cups': {
      'cup': 1,
      'ml': 236.588,
      'liter': 0.236588,
      'tablespoon': 16,
      'teaspoon': 48,
      'fluid ounce': 8,
    },
    'أكواب': {
      'كوب': 1,
      'مل لتر': 236.588,
      'لتر': 0.236588,
      'ملعقة طعام': 16,
      'ملعقة شاي': 48,
      'اونس سائل': 8,
    },
    // ========== LENGTH ==========
    'm': {
      'meter': 1,
      'centimeter': 100,
      'millimeter': 1000,
      'kilometer': 0.001,
      'inch': 39.3701,
      'foot': 3.28084,
      'yard': 1.09361,
      'mile': 0.000621371,
    },
    'meter': {
      'meter': 1,
      'centimeter': 100,
      'millimeter': 1000,
      'kilometer': 0.001,
      'inch': 39.3701,
      'foot': 3.28084,
      'yard': 1.09361,
      'mile': 0.000621371,
    },
    'متر': {
      'متر': 1,
      'سم': 100,
      'مم': 1000,
      'كم': 0.001,
      'انش': 39.3701,
      'قدم': 3.28084,
      'ياردة': 1.09361,
      'ميل': 0.000621371,
    },
    'meters': {
      'meter': 1,
      'centimeter': 100,
      'millimeter': 1000,
      'kilometer': 0.001,
      'inch': 39.3701,
      'foot': 3.28084,
      'yard': 1.09361,
      'mile': 0.000621371,
    },
    'أمتار': {
      'متر': 1,
      'سم': 100,
      'مم': 1000,
      'كم': 0.001,
      'انش': 39.3701,
      'قدم': 3.28084,
      'ياردة': 1.09361,
      'ميل': 0.000621371,
    },
    'cm': {
      'centimeter': 1,
      'meter': 0.01,
      'millimeter': 10,
      'inch': 0.393701,
      'foot': 0.0328084,
    },
    'centimeter': {
      'centimeter': 1,
      'meter': 0.01,
      'millimeter': 10,
      'inch': 0.393701,
      'foot': 0.0328084,
    },
    'سم': {
      'سم': 1,
      'متر': 0.01,
      'مم': 10,
      'انش': 0.393701,
      'قدم': 0.0328084,
    },
    'centimeters': {
      'centimeter': 1,
      'meter': 0.01,
      'millimeter': 10,
      'inch': 0.393701,
      'foot': 0.0328084,
    },
    'سنتيمتر': {
      'سنتيمتر': 1,
      'متر': 0.01,
      'مم': 10,
      'انش': 0.393701,
      'قدم': 0.0328084,
    },
    'in': {
      'inch': 1,
      'centimeter': 2.54,
      'millimeter': 25.4,
      'foot': 0.0833333,
      'yard': 0.0277778,
    },
    'inch': {
      'inch': 1,
      'centimeter': 2.54,
      'millimeter': 25.4,
      'foot': 0.0833333,
      'yard': 0.0277778,
    },
    'انش': {
      'انش': 1,
      'سم': 2.54,
      'مم': 25.4,
      'قدم': 0.0833333,
      'ياردة': 0.0277778,
    },
    'inches': {
      'inch': 1,
      'centimeter': 2.54,
      'millimeter': 25.4,
      'foot': 0.0833333,
      'yard': 0.0277778,
    },
    'بوصة': {
      'بوصة': 1,
      'سم': 2.54,
      'مم': 25.4,
      'قدم': 0.0833333,
      'ياردة': 0.0277778,
    },
    'ft': {
      'foot': 1,
      'meter': 0.3048,
      'centimeter': 30.48,
      'inch': 12,
      'yard': 0.333333,
      'mile': 0.000189394,
    },
    'foot': {
      'foot': 1,
      'meter': 0.3048,
      'centimeter': 30.48,
      'inch': 12,
      'yard': 0.333333,
      'mile': 0.000189394,
    },
    'قدم': {
      'قدم': 1,
      'متر': 0.3048,
      'سم': 30.48,
      'انش': 12,
      'ياردة': 0.333333,
      'ميل': 0.000189394,
    },
    'feet': {
      'foot': 1,
      'meter': 0.3048,
      'centimeter': 30.48,
      'inch': 12,
      'yard': 0.333333,
      'mile': 0.000189394,
    },
    'أقدام': {
      'قدم': 1,
      'متر': 0.3048,
      'سم': 30.48,
      'انش': 12,
      'ياردة': 0.333333,
      'ميل': 0.000189394,
    },
    // ========== AREA ==========
    'sqm': {
      'square meter': 1,
      'square kilometer': 0.000001,
      'square foot': 10.7639,
      'square inch': 1550,
      'hectare': 0.0001,
      'acre': 0.000247105,
    },
    'square meter': {
      'square meter': 1,
      'square kilometer': 0.000001,
      'square foot': 10.7639,
      'square inch': 1550,
      'hectare': 0.0001,
      'acre': 0.000247105,
    },
    'متر مربع': {
      'متر مربع': 1,
      'كم مربع': 0.000001,
      'قدم مربع': 10.7639,
      'انش مربع': 1550,
      'هكتار': 0.0001,
      'فدان': 0.000247105,
    },
    'sqf': {
      'square foot': 1,
      'square meter': 0.092903,
      'square inch': 144,
      'acre': 0.0000229568,
    },
    'square foot': {
      'square foot': 1,
      'square meter': 0.092903,
      'square inch': 144,
      'acre': 0.0000229568,
    },
    'قدم مربع': {
      'قدم مربع': 1,
      'متر مربع': 0.092903,
      'انش مربع': 144,
      'فدان': 0.0000229568,
    },
    'acre': {
      'acre': 1,
      'square meter': 4046.86,
      'hectare': 0.404686,
      'square foot': 43560,
    },
    'فدان': {
      'فدان': 1,
      'متر مربع': 4046.86,
      'هكتار': 0.404686,
      'قدم مربع': 43560,
    },

    // ========== TIME ==========
    'sec': {
      'second': 1,
      'millisecond': 1000,
      'minute': 1 / 60,
      'hour': 1 / 3600,
      'day': 1 / 86400,
    },
    'second': {
      'second': 1,
      'millisecond': 1000,
      'minute': 1 / 60,
      'hour': 1 / 3600,
      'day': 1 / 86400,
    },
    'ثانية': {
      'ثانية': 1,
      'مل ثانية': 1000,
      'دقيقة': 1 / 60,
      'ساعة': 1 / 3600,
      'يوم': 1 / 86400,
    },
    'seconds': {
      'second': 1,
      'millisecond': 1000,
      'minute': 1 / 60,
      'hour': 1 / 3600,
      'day': 1 / 86400,
    },
    'ثواني': {
      'ثانية': 1,
      'مل ثانية': 1000,
      'دقيقة': 1 / 60,
      'ساعة': 1 / 3600,
      'يوم': 1 / 86400,
    },
    'min': {
      'minute': 1,
      'second': 60,
      'hour': 1 / 60,
      'day': 1 / 1440,
    },
    'minute': {
      'minute': 1,
      'second': 60,
      'hour': 1 / 60,
      'day': 1 / 1440,
    },
    'دقيقة': {
      'دقيقة': 1,
      'ثانية': 60,
      'ساعة': 1 / 60,
      'يوم': 1 / 1440,
    },
    'minutes': {
      'minute': 1,
      'second': 60,
      'hour': 1 / 60,
      'day': 1 / 1440,
    },
    'دقائق': {
      'دقيقة': 1,
      'ثانية': 60,
      'ساعة': 1 / 60,
      'يوم': 1 / 1440,
    },
    'hr': {
      'hour': 1,
      'minute': 60,
      'second': 3600,
      'day': 1 / 24,
      'week': 1 / 168,
    },
    'hour': {
      'hour': 1,
      'minute': 60,
      'second': 3600,
      'day': 1 / 24,
      'week': 1 / 168,
    },
    'ساعة': {
      'ساعة': 1,
      'دقيقة': 60,
      'ثانية': 3600,
      'يوم': 1 / 24,
      'أسبوع': 1 / 168,
    },
    'hours': {
      'hour': 1,
      'minute': 60,
      'second': 3600,
      'day': 1 / 24,
      'week': 1 / 168,
    },
    'ساعات': {
      'ساعة': 1,
      'دقيقة': 60,
      'ثانية': 3600,
      'يوم': 1 / 24,
      'أسبوع': 1 / 168,
    },

    // ========== QUANTITY/COUNTING UNITS ==========
    'pc': {
      'piece': 1,
      'dozen': 1 / 12,
      'half dozen': 1 / 6,
      'score': 1 / 20,
      'gross': 1 / 144,
      'ream': 1 / 500, // for paper
      'pair': 1 / 2,
      'unit': 1,
    },
    'piece': {
      'piece': 1,
      'dozen': 1 / 12,
      'half dozen': 1 / 6,
      'score': 1 / 20,
      'gross': 1 / 144,
      'ream': 1 / 500, // for paper
      'pair': 1 / 2,
      'unit': 1,
    },
    'قطعة': {
      'قطعة': 1,
      'دزينة': 1 / 12,
      'نصف دزينة': 1 / 6,
      'عشرون': 1 / 20,
      'جروس': 1 / 144,
      'رزمة': 1 / 500,
      'زوج': 1 / 2,
      'وحدة': 1,
    },
    'pcs': {
      'piece': 1,
      'dozen': 1 / 12,
      'half dozen': 1 / 6,
      'score': 1 / 20,
      'gross': 1 / 144,
      'ream': 1 / 500, // for paper
      'pair': 1 / 2,
      'unit': 1,
    },
    'pieces': {
      'piece': 1,
      'dozen': 1 / 12,
      'half dozen': 1 / 6,
      'score': 1 / 20,
      'gross': 1 / 144,
      'ream': 1 / 500, // for paper
      'pair': 1 / 2,
      'unit': 1,
    },
    'قطعات': {
      'قطعة': 1,
      'دزينة': 1 / 12,
      'نصف دزينة': 1 / 6,
      'عشرون': 1 / 20,
      'جروس': 1 / 144,
      'رزمة': 1 / 500,
      'زوج': 1 / 2,
      'وحدة': 1,
    },
    'dz': {
      'dozen': 1,
      'piece': 12,
      'half dozen': 2,
      'score': 12 / 20,
      'gross': 1 / 12,
      'pair': 6,
    },
    'dozen': {
      'dozen': 1,
      'piece': 12,
      'half dozen': 2,
      'score': 12 / 20,
      'gross': 1 / 12,
      'pair': 6,
    },
    'دزينة': {
      'دزينة': 1,
      'قطعة': 12,
      'نصف دزينة': 2,
      'عشرون': 12 / 20,
      'جروس': 1 / 12,
      'زوج': 6,
    },
    'half dozen': {
      'half dozen': 1,
      'piece': 6,
      'dozen': 1 / 2,
      'pair': 3,
    },
    'نصف دزينة': {
      'نصف دزينة': 1,
      'قطعة': 6,
      'دزينة': 1 / 2,
      'زوج': 3,
    },
    'score': {
      // 1 score = 20 pieces
      'score': 1,
      'piece': 20,
      'dozen': 20 / 12,
      'gross': 20 / 144,
    },
    'عشرون': {
      'عشرون': 1,
      'قطعة': 20,
      'دزينة': 20 / 12,
      'جروس': 20 / 144,
    },
    'gross': {
      // 1 gross = 144 pieces
      'gross': 1,
      'piece': 144,
      'dozen': 12,
      'score': 144 / 20,
    },
    'جروس': {
      'جروس': 1,
      'قطعة': 144,
      'دزينة': 12,
      'عشرون': 144 / 20,
    },
    'pair': {
      'pair': 1,
      'piece': 2,
      'dozen': 1 / 6,
      'half dozen': 1 / 3,
    },
    'زوج': {
      'زوج': 1,
      'قطعة': 2,
      'دزينة': 1 / 6,
      'نصف دزينة': 1 / 3,
    },
    'unit': {
      // Synonymous with 'piece'
      'unit': 1,
      'piece': 1,
      'dozen': 12,
    },
    'وحدة': {
      'وحدة': 1,
      'قطعة': 1,
      'دزينة': 12,
    },
    'ream': {
      // Typically for paper (500 sheets)
      'ream': 1,
      'piece': 500,
      'dozen': 500 / 12,
    },
    'رزمة': {
      'رزمة': 1,
      'قطعة': 500,
      'دزينة': 500 / 12,
    },

    // Additional useful quantity units
    'hundred': {
      'hundred': 1,
      'piece': 1 / 100,
      'dozen': 12 / 100,
      'thousand': 10,
    },
    'مئة': {
      'مئة': 1,
      'قطعة': 1 / 100,
      'دزينة': 12 / 100,
      'ألف': 10,
    },
    'thousand': {
      'thousand': 1,
      'piece': 1 / 1000,
      'hundred': 1 / 10,
    },
    'ألف': {
      'ألف': 1,
      'قطعة': 1 / 1000,
      'مئة': 1 / 10,
    },
    'million': {
      'million': 1,
      'piece': 1 / 1000000,
      'thousand': 1 / 1000,
    },
    'مليون': {
      'مليون': 1,
      'قطعة': 1 / 1000000,
      'ألف': 1 / 1000,
    },

    // ========== SPEED ==========
    'km per hour': {
      'km/h': 1,
      'm/s': 0.277778,
      'mph': 0.621371,
      'knot': 0.539957,
    },
    'km/h': {
      'km/h': 1,
      'm/s': 0.277778,
      'mph': 0.621371,
      'knot': 0.539957,
    },
    'كم في الساعه': {
      'كم/س': 1,
      'م/ث': 0.277778,
      'ميل/س': 0.621371,
      'عقدة': 0.539957,
    },
    'كم في ساعه': {
      'كم/س': 1,
      'م/ث': 0.277778,
      'ميل/س': 0.621371,
      'عقدة': 0.539957,
    },
    'كم/س': {
      'كم/س': 1,
      'م/ث': 0.277778,
      'ميل/س': 0.621371,
      'عقدة': 0.539957,
    },
    'miles per hour': {
      'mph': 1,
      'km/h': 1.60934,
      'm/s': 0.44704,
      'knot': 0.868976,
    },
    'mph': {
      'mph': 1,
      'km/h': 1.60934,
      'm/s': 0.44704,
      'knot': 0.868976,
    },
    'ميل/س': {
      'ميل/س': 1,
      'كم/س': 1.60934,
      'م/ث': 0.44704,
      'عقدة': 0.868976,
    },
    'ميل في الساعه': {
      'ميل/س': 1,
      'كم/س': 1.60934,
      'م/ث': 0.44704,
      'عقدة': 0.868976,
    },
    'ميل في ساعه': {
      'ميل/س': 1,
      'كم/س': 1.60934,
      'م/ث': 0.44704,
      'عقدة': 0.868976,
    },
    // ========== PRESSURE ==========
    'pascal': {
      'pascal': 1,
      'bar': 0.00001,
      'psi': 0.000145038,
      'atm': 0.00000986923,
    },
    'باسكال': {
      'باسكال': 1,
      'بار': 0.00001,
      'باوند/بوصة²': 0.000145038,
      'جو': 0.00000986923,
    },
    'psi': {
      'psi': 1,
      'pascal': 6894.76,
      'bar': 0.0689476,
      'atm': 0.068046,
    },
    'باوند/بوصة²': {
      'باوند/بوصة²': 1,
      'باسكال': 6894.76,
      'بار': 0.0689476,
      'جو': 0.068046,
    },
  };
}

class PaymentTerms {
  // Payment terms
  final paymentTerms = [
    'Cash',
    'Due on Receipt',
    'Credit 15 days',
    'Credit 30 days',
    'Credit 45 days',
    'Credit 60 days',
    'Credit 90 days',
    'Credit 120 days',
  ];
}

class ConstantStrings {
  final String appleAppStoreTermsText = '''
APPLE APP STORE TERMS AND CONDITIONS

Last Updated: [Current Date]

1. AGREEMENT TO TERMS

These Terms constitute a legally binding agreement between you and Apple regarding your use of the App Store.

2. APPLE ID AND ACCOUNT

You need an Apple ID to use the App Store. You are responsible for maintaining the confidentiality of your account.

3. APP STORE CONTENT

The App Store offers apps, games, in-app purchases, and subscriptions ("Content") from Apple and third-party developers.

4. PAYMENTS AND SUBSCRIPTIONS

Purchases are billed to your Apple ID account. Subscriptions automatically renew unless turned off at least 24 hours before the end of the current period.

5. LICENSE TO CONTENT

When you purchase Content, you receive a limited, non-transferable license to use that Content as permitted by these Terms.

6. CANCELLATION AND REFUNDS

You can manage subscriptions in Settings > [your name] > Subscriptions. For refund requests, contact Apple Support.

7. THIRD-PARTY CONTENT

Content from third-party developers is subject to their own terms and privacy policies in addition to these Terms.

8. DISCLAIMER OF WARRANTIES

THE APP STORE AND CONTENT ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.

9. LIMITATION OF LIABILITY

TO THE MAXIMUM EXTENT PERMITTED BY LAW, APPLE SHALL NOT BE LIABLE FOR ANY INDIRECT DAMAGES.

For the complete Apple Media Services Terms and Conditions, visit:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
''';

  final String googlePlayTermsText = '''
GOOGLE PLAY TERMS OF SERVICE

Last Updated: [Current Date]

1. INTRODUCTION

These Google Play Terms of Service ("Terms") govern your use of Google Play and any content, products, services, and applications made available by developers through Google Play (collectively, "Content").

2. ACCEPTANCE OF TERMS

By using Google Play, you agree to be bound by these Terms and Google's Privacy Policy.

3. USING GOOGLE PLAY

You may use Google Play to browse, download (where available), and use Content. Some Content may be offered for a fee, including subscriptions.

4. PAYMENTS AND SUBSCRIPTIONS

Purchases on Google Play are processed by Google Payment Corp. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.

5. CONTENT LICENSES

When you acquire Content, you receive a license to use that Content as described in these Terms. The license is for personal, non-commercial use.

6. CANCELLATIONS AND REFUNDS

You can cancel subscriptions through your Google Play account settings. Refunds may be available in certain circumstances as described in Google's refund policy.

7. DEVELOPER TERMS

Additional terms from developers may apply to specific Content.

8. DISCLAIMERS AND LIMITATIONS

GOOGLE PROVIDES GOOGLE PLAY "AS IS" WITHOUT WARRANTIES. GOOGLE'S LIABILITY IS LIMITED AS PROVIDED BY LAW.

9. CHANGES TO TERMS

Google may modify these Terms at any time. Continued use constitutes acceptance of modified Terms.

For the complete Google Play Terms of Service, visit:
https://play.google.com/intl/en_us/about/play-terms/
''';

  final String active = 'active';
  final String cancel = 'cancel';
}
