class PhoneValidators {
  static Map<String, int> phoneValidation = {
    // North America
    'US': 10, // United States
    'CA': 10, // Canada
    'MX': 10, // Mexico

    // Caribbean
    'CU': 8, // Cuba
    'DO': 10, // Dominican Republic
    'PR': 10, // Puerto Rico
    'JM': 10, // Jamaica
    'BS': 10, // Bahamas
    'BB': 10, // Barbados

    // Central America
    'GT': 8, // Guatemala
    'HN': 8, // Honduras
    'SV': 8, // El Salvador
    'NI': 8, // Nicaragua
    'CR': 8, // Costa Rica
    'PA': 8, // Panama
    'BZ': 7, // Belize

    // South America
    'BR': 11, // Brazil (11 with cell phone prefix)
    'AR': 10, // Argentina
    'CO': 10, // Colombia
    'VE': 10, // Venezuela
    'PE': 9, // Peru
    'CL': 9, // Chile
    'EC': 9, // Ecuador
    'BO': 8, // Bolivia
    'PY': 9, // Paraguay
    'UY': 8, // Uruguay
    'GY': 7, // Guyana
    'SR': 7, // Suriname
    'GF': 10, // French Guiana

    // Western Europe
    'GB': 10, // United Kingdom
    'FR': 9, // France
    'DE': 11, // Germany (varies, 10-11)
    'IT': 10, // Italy
    'ES': 9, // Spain
    'PT': 9, // Portugal
    'IE': 9, // Ireland
    'NL': 9, // Netherlands
    'BE': 9, // Belgium
    'LU': 9, // Luxembourg
    'MC': 8, // Monaco
    'CH': 9, // Switzerland
    'AT': 10, // Austria
    'LI': 7, // Liechtenstein

    // Northern Europe
    'DK': 8, // Denmark
    'NO': 8, // Norway
    'SE': 9, // Sweden
    'FI': 9, // Finland
    'IS': 7, // Iceland
    'FO': 6, // Faroe Islands
    'GL': 6, // Greenland

    // Eastern Europe
    'RU': 10, // Russia
    'UA': 9, // Ukraine
    'PL': 9, // Poland
    'CZ': 9, // Czech Republic
    'SK': 9, // Slovakia
    'HU': 9, // Hungary
    'RO': 9, // Romania
    'BG': 9, // Bulgaria
    'RS': 9, // Serbia
    'HR': 9, // Croatia
    'SI': 9, // Slovenia
    'BA': 8, // Bosnia and Herzegovina
    'MK': 8, // North Macedonia
    'AL': 9, // Albania
    'ME': 8, // Montenegro
    'XK': 8, // Kosovo
    'EE': 8, // Estonia
    'LV': 8, // Latvia
    'LT': 8, // Lithuania
    'BY': 9, // Belarus
    'MD': 8, // Moldova

    // Middle East
    'LB': 8, // Lebanon
    'SA': 9, // Saudi Arabia
    'AE': 9, // United Arab Emirates
    'IL': 9, // Israel
    'TR': 10, // Turkey
    'IR': 10, // Iran
    'IQ': 10, // Iraq
    'SY': 9, // Syria
    'JO': 9, // Jordan
    'KW': 8, // Kuwait
    'QA': 8, // Qatar
    'BH': 8, // Bahrain
    'OM': 8, // Oman
    'YE': 9, // Yemen
    'CY': 8, // Cyprus

    // Asia
    'CN': 11, // China
    'IN': 10, // India
    'JP': 10, // Japan
    'KR': 10, // South Korea
    'KP': 8, // North Korea
    'TW': 9, // Taiwan
    'HK': 8, // Hong Kong
    'MO': 8, // Macau
    'MN': 8, // Mongolia

    // Southeast Asia
    'ID': 11, // Indonesia
    'MY': 10, // Malaysia
    'SG': 8, // Singapore
    'TH': 9, // Thailand
    'VN': 10, // Vietnam
    'PH': 10, // Philippines
    'MM': 9, // Myanmar
    'KH': 9, // Cambodia
    'LA': 10, // Laos
    'BN': 7, // Brunei
    'TL': 8, // Timor-Leste

    // South Asia
    'PK': 10, // Pakistan
    'BD': 10, // Bangladesh
    'LK': 9, // Sri Lanka
    'NP': 10, // Nepal
    'BT': 8, // Bhutan
    'MV': 7, // Maldives
    'AF': 9, // Afghanistan

    // Oceania
    'AU': 9, // Australia
    'NZ': 9, // New Zealand
    'PG': 8, // Papua New Guinea
    'FJ': 7, // Fiji
    'SB': 7, // Solomon Islands
    'VU': 7, // Vanuatu
    'NC': 6, // New Caledonia
    'PF': 8, // French Polynesia
    'WS': 7, // Samoa
    'TO': 7, // Tonga

    // Africa - North
    'EG': 10, // Egypt
    'DZ': 9, // Algeria
    'MA': 9, // Morocco
    'TN': 8, // Tunisia
    'LY': 9, // Libya
    'SD': 9, // Sudan
    'SS': 9, // South Sudan

    // Africa - West
    'NG': 10, // Nigeria
    'GH': 9, // Ghana
    'CI': 8, // Ivory Coast
    'SN': 9, // Senegal
    'CM': 9, // Cameroon
    'ML': 8, // Mali
    'BF': 8, // Burkina Faso
    'NE': 8, // Niger
    'TG': 8, // Togo
    'BJ': 8, // Benin
    'MR': 8, // Mauritania
    'GM': 7, // Gambia
    'GN': 7, // Guinea
    'SL': 8, // Sierra Leone
    'LR': 7, // Liberia
    'CV': 7, // Cape Verde

    // Africa - East
    'KE': 9, // Kenya
    'ET': 9, // Ethiopia
    'TZ': 9, // Tanzania
    'UG': 9, // Uganda
    'RW': 9, // Rwanda
    'BI': 8, // Burundi
    'SO': 8, // Somalia
    'DJ': 8, // Djibouti
    'ER': 7, // Eritrea
    'SC': 7, // Seychelles
    'KM': 7, // Comoros

    // Africa - Central
    'CD': 9, // DR Congo
    'CG': 9, // Republic of Congo
    'GA': 8, // Gabon
    'GQ': 9, // Equatorial Guinea
    'CF': 8, // Central African Republic
    'TD': 8, // Chad

    // Africa - South
    'ZA': 9, // South Africa
    'NA': 9, // Namibia
    'BW': 8, // Botswana
    'ZW': 9, // Zimbabwe
    'ZM': 9, // Zambia
    'MW': 9, // Malawi
    'MZ': 9, // Mozambique
    'AO': 9, // Angola
    'LS': 8, // Lesotho
    'SZ': 8, // Eswatini
    'MG': 9, // Madagascar
    'MU': 8, // Mauritius
    'RE': 10, // Réunion
  };

  static int getPhoneNumberLength(String countryCode) {
    return phoneValidation[countryCode] ??
        10; // Default to 10 if country code is not found
  }
}
