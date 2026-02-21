script_version('0.0.2 dev')
--[[ 0.0.1 dev -> 0.0.2 dev - Добавлена полная поддержка для НФТ-Контейнеров
]]

local effil = require("effil")
local imgui = require 'mimgui'
local ffi = require 'ffi'
local faicons = require('fAwesome6')
local sampEvents = require('lib.samp.events')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local JsonStatus, Json = pcall(require, 'carbjsonconfig')
assert(JsonStatus, '[FarmLog] carbJsonConfg lib not found')

function sendCef(str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetBitStreamWriteInt32(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function cef_emul(str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteString(bs, str)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end

local FarmData = {
    selectedDateIndex = os.date('%d.%m.%y'),
    selectedPeriod = 'days',
    current_editing = '',
    search_filter = imgui.ImGuiTextFilter(),
    input_price = imgui.new.int(0)
}

local imguiJson = {
    flag_nft = false, -- На всякий случай будет в JSON
    totalProfitSA = 0,
    totalProfitAZ = 0,
    current_payday_multiplier = 2,
    vc = imgui.new.int(118),
    az = imgui.new.int(60000),
    premiumvipy_status = imgui.new.bool(false),
    premiumvipy_status_parse_price = imgui.new.bool(false),
    midas3sloti_status = imgui.new.bool(false),
    midas3sloti_status_parse_price = imgui.new.bool(false),
    leshiy_status = imgui.new.bool(false),
    leshiy_status_parse_price = imgui.new.bool(false),
    rassrochka_status = imgui.new.bool(false),
    rassrochka_status_parse_price = imgui.new.bool(false),
    premiumvip_status = imgui.new.bool(false),
    premiumvip_status_parse_price = imgui.new.bool(false),
    addvip_status = imgui.new.bool(false),
    addvip_status_parse_price = imgui.new.bool(false),
    kosa_marci_status = imgui.new.bool(false),
    kosa_marci_status_parse_price = imgui.new.bool(false),
    grazdan_taloni_status = imgui.new.bool(false),
    grazdan_taloni_status_parse_price = imgui.new.bool(false),
    zarplata_status = imgui.new.bool(false),
    zarplata_status_parse_price = imgui.new.bool(false),
    deposit_status = imgui.new.bool(false),
    deposit_status_parse_price = imgui.new.bool(false),
    market_status = imgui.new.bool(false),
    market_status_parse_price = imgui.new.bool(false),
    total_roulette_status = imgui.new.bool(false),
    total_roulette_status_parse_price = imgui.new.bool(false),
    total_boxes_status = imgui.new.bool(false),
    total_boxes_status_parse_price = imgui.new.bool(false),
    obrez_status = imgui.new.bool(false),
    obrez_status_parse_price = imgui.new.bool(false),
    total_business_status = imgui.new.bool(false),
    total_business_status_parse_price = imgui.new.bool(false),
    kosa_marci_bitcoin_status = imgui.new.bool(false),
    kosa_marci_bitcoin_status_parse_price = imgui.new.bool(false),
    podarki_acs_ohr_status = imgui.new.bool(false),
    podarki_acs_ohr_status_parse_price = imgui.new.bool(false),
    az_acs_ohr_status = imgui.new.bool(false),
    az_acs_ohr_status_parse_price = imgui.new.bool(false),
    ribmoneta_acs_ohr_status = imgui.new.bool(false),
    ribmoneta_acs_ohr_status_parse_price = imgui.new.bool(false),
    vc_acs_ohr_status = imgui.new.bool(false),
    vc_acs_ohr_status_parse_price = imgui.new.bool(false),
    mirage_status = imgui.new.bool(false),
    mirage_status_parse_price = imgui.new.bool(false),
    payday_status = imgui.new.bool(false),
    payday_status_parse_price = imgui.new.bool(false),
    totalProfitAZ_status = imgui.new.bool(false),
    totalProfitAZ_status_parse_price = imgui.new.bool(false),
    totalProfitSA_status = imgui.new.bool(false),
    totalProfitSA_status_parse_price = imgui.new.bool(false),
    finka_business_status = imgui.new.bool(false),
    finka_business_status_parse_price = imgui.new.bool(false),
    quest_business_status = imgui.new.bool(false),
    quest_business_status_parse_price = imgui.new.bool(false),
    finka_lv_territory_status = imgui.new.bool(false),
    finka_lv_territory_status_parse_price = imgui.new.bool(false),
    altushka_status = imgui.new.bool(false),
    altushka_status_parse_price = imgui.new.bool(false),
    space_heart_status = imgui.new.bool(false),
    space_heart_status_parse_price = imgui.new.bool(false),
    micro_tec_status = imgui.new.bool(false),
    micro_tec_status_parse_price = imgui.new.bool(false),
    nft_kont_status = imgui.new.bool(false),
    nft_kont_status_parse_price = imgui.new.bool(false),
    oskolok_nft_price = imgui.new.int(40000000),
    primogem_price = imgui.new.int(1500000),
    market_price = imgui.new.int(50000),
    ribmoneta_price = imgui.new.int(100000),
    podarok_price = imgui.new.int(25000),
    grazdan_taloni_price = imgui.new.int(10000),
    moneta_mirage_price = imgui.new.int(800000),
    bronze_r_price = imgui.new.int(25000),
    silver_r_price = imgui.new.int(100000),
    gold_r_price = imgui.new.int(350000),
    platinum_r_price = imgui.new.int(650000),
    larec_premiya_price = imgui.new.int(250000),
    super_car_box_price = imgui.new.int(450000),
    obrez_price = imgui.new.int(50000),
    bitcoin_price = imgui.new.int(80000),
    finka_slider_business = imgui.new.int(0),
    concept_car_luxury_price = imgui.new.int(1),
    products_carrier_box_price = imgui.new.int(1),
    fisher_box_price = imgui.new.int(1),
    treasure_hunter_box_price = imgui.new.int(1),
    crafter_box_price = imgui.new.int(1),
    custom_acessories_box_price = imgui.new.int(1),
    mortal_combat_box_price = imgui.new.int(1),
    random_box_price = imgui.new.int(1),
    oligarch_box_price = imgui.new.int(1),
    organization_box_price = imgui.new.int(1),
    fortnite_box_price = imgui.new.int(1),
    nostalgic_box_price = imgui.new.int(1),
    rare_yellow_box_price = imgui.new.int(1),
    rare_red_box_price = imgui.new.int(1),
    rare_blue_box_price = imgui.new.int(1),
    super_auto_box_price = imgui.new.int(1),
    super_moto_box_price = imgui.new.int(1),
    marvel_box_price = imgui.new.int(1),
    gentelman_box_price = imgui.new.int(1),
    minecraft_box_price = imgui.new.int(1),
    second_hand_box_price = imgui.new.int(1),
    larec_tidex_price = imgui.new.int(1),
    larec_pasxa_2024_price = imgui.new.int(1),
    larec_family_ohra_price = imgui.new.int(1),
    larec_hallowen_2024_price = imgui.new.int(1),
    larec_garbage_collector_price = imgui.new.int(1),
    larec_cock_price = imgui.new.int(1),
    larec_vc_price = imgui.new.int(1),
    micro_tec_price = imgui.new.int(1),
    benzopila_price = imgui.new.int(1),
    silver_price = imgui.new.int(1),
    gold_price = imgui.new.int(1),
    oskolok_zatochka_nft_price = imgui.new.int(1),
    nft_sert_elegy_price = imgui.new.int(1),
    nft_sert_cheetah_price = imgui.new.int(1),
    nft_sert_carting_price = imgui.new.int(1),
    nft_sert_phoenix_price = imgui.new.int(1),
    nft_restavracia_acs_price = imgui.new.int(1)
}
Json.load(getWorkingDirectory() .. "\\config\\imguiJson7.json", imguiJson);
imguiJson()

local FarmLog = {
    days = {},
    weeks = {},
    months = {}
}
Json.load(getWorkingDirectory() .. "\\config\\FarmLog.json", FarmLog);
FarmLog()

local months = {
    [1]="Январь", [2]="Февраль", [3]="Март", [4]="Апрель", 
    [5]="Май", [6]="Июнь", [7]="Июль", [8]="Август",
    [9]="Сентябрь", [10]="Октябрь", [11]="Ноябрь", [12]="Декабрь"
}

local function formatDate()
    local m = tonumber(os.date("%m"))
    return months[m] .. " (" .. os.date("%m") .. "), " .. os.date("%Y")
end

local function getWeekRange(date) -- явный параметр
    local d, m, y = date:match("(%d+).(%d+).(%d+)")
    local t = os.time({day = tonumber(d), month = tonumber(m), year = 2000 + tonumber(y)})
    local wday = tonumber(os.date("%w", t)) -- 0-6 (0=воскресенье)
    wday = wday == 0 and 6 or wday-1 -- преобразуем в 0-5 (пн-сб), 6 (вс)
    local start = os.date("*t", t - wday*86400)
    local end_ = os.date("*t", t + (6-wday)*86400)
    return ("%02d.%02d-%02d.%02d"):format(start.day, start.month, end_.day, end_.month)
end

local currentDate = os.date('%d.%m.%y')
local currentWeek = getWeekRange(os.date('%d.%m.%y'))
local currentMonth = formatDate()

if FarmLog.days[currentDate] == nil then
    FarmLog.days[currentDate] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
end

if FarmLog.weeks[currentWeek] == nil then
    FarmLog.weeks[currentWeek] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
end

if FarmLog.months[currentMonth] == nil then
    FarmLog.months[currentMonth] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
end

local isFarmLogSaved = false
function FarmLogTimer()
    if isFarmLogSaved then return end
    isFarmLogSaved = true
    lua_thread.create(function()
        sampAddChatMessage('Вот здесь wait', -1)
        wait(3000)
        sampAddChatMessage('А вот здесь 3 секунды прошло', -1)
        FarmLog()
        isFarmLogSaved = false
    end)
end

local isImguiJsonSaved = false
function imguiJsonTimer()
    if isImguiJsonSaved then return end
    isImguiJsonSaved = true
    lua_thread.create(function()
        wait(3000)
        imguiJson()
        isImguiJsonSaved = false
    end)
end

local JS = [[
if (0 == document.getElementsByClassName("lua-btn-take-all").length) {
    // Копируем ВСЕ вспомогательные функции из оригинала
    function utils_noop() {}
    function store_writable(e, l = utils_noop) {
        let a;
        const t = new Set;
        function s(l) {
            if (utils_safe_not_equal(e, l) && (e = l, a)) {
                const l = !subscriber_queue.length;
                for (const l of t) l[1](), subscriber_queue.push(l, e);
                if (l) {
                    for (let e = 0; e < subscriber_queue.length; e += 2) subscriber_queue[e][0](subscriber_queue[e + 1]);
                    subscriber_queue.length = 0
                }
            }
        }
        function n(l) {
            s(l(e))
        }
        return {
            set: s,
            update: n,
            subscribe: function(o, r = utils_noop) {
                const c = [o, r];
                return t.add(c), 1 === t.size && (a = l(s, n) || utils_noop), o(e), () => {
                    t.delete(c), 0 === t.size && a && (a(), a = null)
                }
            }
        }
    }
    function utils_subscribe(e, ...l) {
        if (null == e) {
            for (const e of l) e(void 0);
            return utils_noop
        }
        const a = e.subscribe(...l);
        return a.unsubscribe ? () => a.unsubscribe() : a
    }
    function get_store_value(e) {
        let l;
        return utils_subscribe(e, (e => l = e))(), l
    }
    var browserId = store_writable(0),
        videoBackgroundVisible = store_writable(!1),
        battleroyaleMapVisible = store_writable(!1),
        battleRoyaleHudMinimized = store_writable(!1),
        radarRect = store_writable({});
    function _typeof(e) {
        return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
            return typeof e
        } : function(e) {
            return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
        }, _typeof(e)
    }
    var formatClientMessageArgs = function() {
            return (arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : []).map((function(e) {
                return "object" === _typeof(e) ? JSON.stringify(e) : e
            })).join("|")
        },
        cef_sendClientMessage = function(e) {
            for (var l = arguments.length, a = new Array(l > 1 ? l - 1 : 0), t = 1; t < l; t++) a[t - 1] = arguments[t];
            var s = "".concat(e).concat(0 !== a.length ? "|" : "").concat(formatClientMessageArgs(a));
            window.cef ? window.cef.SendMessage(s, get_store_value(browserId)) : console.log(s)
        };
    
    // CSS стили - адаптируем под бизнес
    function addCss(e) {
        var l = document.createElement("style");
        l.type = "text/css", l.styleSheet ? l.styleSheet.cssText = e : l.appendChild(document.createTextNode(e)), document.getElementsByTagName("head")[0].appendChild(l)
    }
    
    // Стили как в оригинале, но для нашей кнопки
    addCss("\n.lua-btn-take-all {\n    align-items: center;\n    background: #007882;\n    cursor: pointer;\n    display: flex;\n    height: 100%;\n    justify-content: center;\n    position: relative;\n    transition: background .2s linear, color .2s linear;\n    width: 100%;\n    border-radius: 4px;\n    margin-left: 5px;\n}\n.lua-btn-take-all:hover {\n    background: #005a62;\n}\n.lua-btn-take-all-text {\n    color: #fff;\n    font-family: GothamPro-Light;\n    font-size: max(calc((var(--global-scale)*16*var(--global-scale) - var(--global-scale)*16*var(--global-scale)*0.44)/(var(--global-scale)*1920 - var(--global-scale)*800))*100vw + calc((var(--global-scale)*16*var(--global-scale)*0.44 - (var(--global-scale)*16*var(--global-scale) - var(--global-scale)*16*var(--global-scale)*0.44)/(var(--global-scale)*1920 - var(--global-scale)*800)*800*var(--global-scale))*1px), 1px);\n}\n");
    
    // Функция вставки после элемента (из оригинала)
    function insertAfter(e, l) {
        e.parentNode.insertBefore(l, e.nextSibling)
    }
    
    // Ищем кнопку "Пополнить" - ТОЧНЫЙ селектор по вашим данным
    const originalButton = document.querySelector('.business-info__menu-money-button.business-info__menu-money-button--small.svelte-1nl4c71');
    
    if (originalButton) {
        // Клонируем оригинальную кнопку
        const newButton = originalButton.cloneNode(true);
        
        // Меняем классы и содержимое - КАК В ОРИГИНАЛЕ
        newButton.className = 'lua-btn-take-all business-info__menu-money-button business-info__menu-money-button--small svelte-1nl4c71';
        
        // Находим текстовый элемент внутри - точный селектор
        const textElement = newButton.querySelector('.business-info__menu-money-button-title.svelte-1nl4c71');
        if (textElement) {
            textElement.textContent = 'Забрать все';
            textElement.className = 'lua-btn-take-all-text business-info__menu-money-button-title svelte-1nl4c71';
        }
        
        // Добавляем обработчик клика - КАК В ОРИГИНАЛЕ
        newButton.addEventListener("click", (function(l) {
            l.preventDefault();
            l.stopPropagation();
            cef_sendClientMessage("business_take_all_money|true");
            return false;
        }));
        
        // Вставляем новую кнопку рядом с оригинальной - КАК В ОРИГИНАЛЕ
        insertAfter(originalButton, newButton);
        
        // Скрываем оригинальную кнопку - ТОЧНО КАК В ОРИГИНАЛЕ
        originalButton.style.display = 'none';
    }
}]]

--[[ Всего в массиве item 9 элементов
    1) Название предмета. Используется для читаемости, и в некоторых imgui.Text
    2) Название предмета №2. Используется в хуках сообщений
    3) Строковое значение под FarmLog[FarmData.selectedPeriod][SelectedDateIndex]
    4) Коэффицинт - значение, вписанное за единицу предмета в интерфейсе. Для чего обернуто, не помню. Обязательно дописать СЮДА!!!!!!!!!!!!!!!!!!!
    5) Строковое значение под imgui.Text, в разделе InputInt
    6) Уникальный id, для раздела InputInt
    7) Тоже самое что четвертый элемент, просто не обернуто. Почему оно так, опять же, не помню. Возможно, четвертый элемент используется во вкладе InputInt, а зачем тогда 7 элемент? Для input вкладки используется кстати 7 элемент, а не 4. LOL
    8) Новый восьмой элемент. Будет показывать либо статус предмета, либо _. Нужно для вызова в InputInt , для того чтобы не показывать лишние предметы. Которые не выбраны пользователем
    9) Тоже, новый элемент. Задача - контроль, нужно ли парсить данный предмет с данных от адреса арз-маркета
]]

local item = {
    [1] = {'Платиновая рулетка', 'платиновую рулетку', 'platinum_r', imgui.new.int(imguiJson.platinum_r_price), 'Цена платиновой рулетки:', '##set_price_platinum_roulette', imguiJson.platinum_r_price, imguiJson.total_roulette_status, imguiJson.total_roulette_status_parse_price},
	[2] = {'Золотая рулетка', 'золотую рулетку', 'gold_r', imgui.new.int(imguiJson.gold_r_price), 'Цена золотой рулетки:', '##set_price_gold_roulette', imguiJson.gold_r_price, imguiJson.total_roulette_status, imguiJson.total_roulette_status_parse_price},
	[3] = {'Серебряная рулетка', 'серебряную рулетку', 'silver_r', imgui.new.int(imguiJson.silver_r_price), 'Цена серебряной рулетки:', '##set_price_silver_roulette', imguiJson.silver_r_price, imguiJson.total_roulette_status, imguiJson.total_roulette_status_parse_price},
	[4] = {'Бронзовая рулетка', 'бронзовую рулетку', 'bronze_r', imgui.new.int(imguiJson.bronze_r_price), 'Цена бронзовой рулетки:', '##set_price_bronze_roulette', imguiJson.bronze_r_price, imguiJson.total_roulette_status, imguiJson.total_roulette_status_parse_price},
	[5] = {'Ларец с премией', 'Ларец с премией', 'larec_premiya', imgui.new.int(imguiJson.larec_premiya_price), 'Цена ларца с премией:', '##set_price_larec_premiya', imguiJson.larec_premiya_price, imguiJson.total_boxes_status, imguiJson.total_boxes_status_parse_price},
	[6] = {'Super Car Box', 'Ларец Super Car', 'super_car_box', imgui.new.int(imguiJson.super_car_box_price), 'Цена ларца Super Car Box:', '##set_price_super_car_box', imguiJson.super_car_box_price, imguiJson.total_boxes_status},
	[7] = {'Concept Car Luxury', 'Concept Car Luxury', 'concept_car_luxury_box', imgui.new.int(imguiJson.concept_car_luxury_price), 'Цена ларца Concept Car Luxury:', '##set_price_concept_car_luxury_box', imguiJson.concept_car_luxury_price, imguiJson.total_boxes_status},
	[8] = {'Ларец развозчика продуктов', 'Ларец развозчика продуктов', 'products_carrier_box', imgui.new.int(imguiJson.products_carrier_box_price), 'Цена ларца развозчика продуктов:', '##set_price_product_carrier_box', imguiJson.products_carrier_box_price, imguiJson.total_boxes_status},
	[9] = {'Ларец рыболова', 'Ларец рыболова', 'fisher_box', imgui.new.int(imguiJson.fisher_box_price), 'Цена ларца рыболова:', '##set_price_fisher_box', imguiJson.fisher_box_price, imguiJson.total_boxes_status},
	[10] = {'Ларец кладоискателя', 'Ларец кладоискателя', 'treasure_hunter_box', imgui.new.int(imguiJson.treasure_hunter_box_price), 'Цена ларца кладоискателя:', '##set_price_treasure_hunter_box', imguiJson.treasure_hunter_box_price, imguiJson.total_boxes_status},
	[11] = {'Ларец крафтера', 'Ларец крафтера', 'crafter_box', imgui.new.int(imguiJson.crafter_box_price),'Цена ларца крафтера:', '##set_price_crafter_box', imguiJson.crafter_box_price, imguiJson.total_boxes_status},
	[12] = {'Ларец кастомных аксессуаров', 'Ларец кастомных аксессуаров', 'custom_accessories_box', imgui.new.int(imguiJson.custom_acessories_box_price),'Цена ларца кастомных акссесуаров:', '##set_price_custom_accessories_box', imguiJson.custom_acessories_box_price, imguiJson.total_boxes_status},
	[13] = {'Ларец Mortal Combat', 'Ларец Mortal Combat', 'mortal_combat_box', imgui.new.int(imguiJson.mortal_combat_box_price), 'Цена ларца Mortal Combat:', '##set_price_mortal_combat_box', imguiJson.mortal_combat_box_price, imguiJson.total_boxes_status},
	[14] = {'Рандомный ларец', 'Рандомный Ларец', 'random_box', imgui.new.int(imguiJson.random_box_price), 'Цена рандомного ларца:', '##set_price_random_box', imguiJson.random_box_price, imguiJson.total_boxes_status},
	[15] = {'Ларец олигарха', 'Ларец Олигарха', 'oligarch_box', imgui.new.int(imguiJson.oligarch_box_price), 'Цена ларца олигарха:', '##set_price_oligarch_box', imguiJson.oligarch_box_price, imguiJson.total_boxes_status},
	[16] = {'Ларец организации', 'Ларец организации', 'organization_box', imgui.new.int(imguiJson.organization_box_price), 'Цена ларца организации:', '##set_price_organization_box', imguiJson.organization_box_price, imguiJson.total_boxes_status},
	[17] = {'Ларец Fortnite', 'Ларец Fortnite', 'fortnite_box', imgui.new.int(imguiJson.fortnite_box_price), 'Цена ларца Fortnite:', '##set_price_fortnite_box', imguiJson.fortnite_box_price, imguiJson.total_boxes_status},
	[18] = {'Ностальгический ящик', 'Ностальгический ящик', 'nostalgic_box', imgui.new.int(imguiJson.nostalgic_box_price), 'Цена ностальгического ящика:', '##set_price_nostalgic_box', imguiJson.nostalgic_box_price, imguiJson.total_boxes_status},
	[19] = {'Rare Box Yellow', 'Rare Box Yellow', 'rare_yellow_box', imgui.new.int(imguiJson.rare_yellow_box_price), 'Цена Rare Yellow Box:', '##set_price_rare_yellow_box', imguiJson.rare_yellow_box_price, imguiJson.total_boxes_status},
	[20] = {'Rare Box Red', 'Rare Box Red', 'rare_red_box', imgui.new.int(imguiJson.rare_red_box_price), 'Цена Rare Red Box:', '##set_price_rare_red_box', imguiJson.rare_red_box_price, imguiJson.total_boxes_status},
	[21] = {'Rare Box Blue', 'Rare Box Blue', 'rare_blue_box', imgui.new.int(imguiJson.rare_blue_box_price), 'Цена Rare Blue Box:', '##set_price_rare_blue_box', imguiJson.rare_blue_box_price, imguiJson.total_boxes_status},
	[22] = {'Супер авто-ящик', 'Супер авто-ящик', 'super_auto_box', imgui.new.int(imguiJson.super_auto_box_price), 'Цена супер авто-ящика:', '##set_price_super_auto_box', imguiJson.super_auto_box_price, imguiJson.total_boxes_status},
	[23] = {'Супер мото-ящик', 'Супер мото-ящик', 'super_moto_box', imgui.new.int(imguiJson.super_moto_box_price), 'Цена мото-ящика:', '##set_price_super_moto_box', imguiJson.super_moto_box_price, imguiJson.total_boxes_status},
	[24] = {'Ящик Marvel', 'Ящик Marvel', 'marvel_box', imgui.new.int(imguiJson.marvel_box_price), 'Цена ящика Marvel:', '##set_price_marvel_box', imguiJson.marvel_box_price, imguiJson.total_boxes_status},
	[25] = {'Ящик Джентельменов', 'Ящик Джентельменов', 'gentleman_box', imgui.new.int(imguiJson.gentelman_box_price), 'Цена ящика джентельменов:', '##set_price_gentelman_box', imguiJson.gentelman_box_price, imguiJson.total_boxes_status},
	[26] = {'Ящик Minecraft', 'Ящик Minecraft', 'minecraft_box', imgui.new.int(imguiJson.minecraft_box_price), 'Цена ящик minecraft:', '##set_price_minecraft_box', imguiJson.minecraft_box_price, imguiJson.total_boxes_status},
	[27] = {'Одежда из секонд-хенда', 'Одежда из секонд-хенда', 'second_hand_box', imgui.new.int(imguiJson.second_hand_box_price), 'Цена одежды из секонд-хенда:', '##set_price_second_hand_box', imguiJson.second_hand_box_price, imguiJson.total_boxes_status},
    [28] = {'Ларец Tidex', 'Ларец Tidex', 'larec_tidex', imgui.new.int(imguiJson.larec_tidex_price), 'Цена ларца Tidex:', '##set_price_larec_tidex', imguiJson.larec_tidex_price, imguiJson.total_boxes_status},
    [29] = {'Пасхальный ларец 2024', 'Пасхальный ларец 2024', 'larec_pasxa_2024', imgui.new.int(imguiJson.larec_pasxa_2024_price), 'Цена пасхального ларца 2024:', '##set_price_larec_pasxa_2024', imguiJson.larec_pasxa_2024_price, imguiJson.total_boxes_status},
    [30] = {'Ларец семейных охранников', 'Ларец семейных охранников', 'larec_family_ohra', imgui.new.int(imguiJson.larec_family_ohra_price), 'Цена ларца семейных охранников:', '##set_price_larec_family_ohra', imguiJson.larec_family_ohra_price, imguiJson.total_boxes_status},
    [31] = {'Ларец хэллоуина 2022', 'Ларец хэллоуина 2022', 'larec_hallowen_2024', imgui.new.int(imguiJson.larec_hallowen_2024_price), 'Цена ларца хэллоуина 2024:', '##set_price_larec_hallowen_2024', imguiJson.larec_hallowen_2024_price, imguiJson.total_boxes_status},
    [32] = {'Ларец мусорщика', 'Ларец мусорщика', 'larec_garbage_collector', imgui.new.int(imguiJson.larec_garbage_collector_price), 'Цена ларца мусорщика:', '##set_price_larec_gargabe_collector', imguiJson.larec_garbage_collector_price, imguiJson.total_boxes_status},
    [33] = {'Ларец петуха', 'Ларец петуха', 'larec_cock', imgui.new.int(imguiJson.larec_cock_price), 'Цена ларца петуха:', '##set_price_larec_cock', imguiJson.larec_cock_price, imguiJson.total_boxes_status},
    [34] = {'Ларец Vice City', 'Ларец Vice City', 'larec_vc', imgui.new.int(imguiJson.larec_vc_price), 'Цена ларца Vice City:', '##set_price_larec_vc', imguiJson.larec_vc_price, imguiJson.total_boxes_status},
    [35] = {'Биткоин', 'Биткоин', 'bitcoin', imgui.new.int(imguiJson.bitcoin_price[0]), 'Цена биткоина:', '##set_price_bitcoin', imguiJson.bitcoin_price, imguiJson.kosa_marci_bitcoin_status},
    [36] = {'Вайс сити денежки', 'Вайс сити денежки', 'vc', imgui.new.int(imguiJson.vc), 'Курс вайс сити денежек:', '##set_price_vc_money', imguiJson.vc, _},
    [37] = {'Подарок', 'Подарок (предмет)', 'podarok', imgui.new.int(imguiJson.podarok_price), 'Цена подарка:', '##set_price_podarok', imguiJson.podarok_price, imguiJson.podarki_acs_ohr_status},
    [38] = {'Рыбная монета', 'Рыбная монета (предмет)', 'ribmoneta', imgui.new.int(imguiJson.ribmoneta_price), 'Цена рыбной монеты:', '##set_price_ribmoneta', imguiJson.ribmoneta_price, imguiJson.ribmoneta_acs_ohr_status},
    [39] = {'Монета миража', 'Монета миража (предмет)', 'moneta_mirage', imgui.new.int(imguiJson.moneta_mirage_price), 'Цена монеты миража:', '##set_price_moneta_mirage', imguiJson.moneta_mirage_price, imguiJson.mirage_status},
    [40] = {'Маркет', 'Маркет (Цена за объяву)', 'market', imgui.new.int(imguiJson.market_price), 'Курс маркетолога за 1 рекламу:', '##set_price_marketolog', imguiJson.market_price, imguiJson.market_status},
    [41] = {'Аз', 'AZ', 'az', imgui.new.int(imguiJson.az), 'Курс AZ:', '##set_price_az', imguiJson.az, _},
    [42] = {'Обрез', 'Оружие Обрезы', 'obrez', imgui.new.int(imguiJson.obrez_price), 'Цена обреза:', '##set_price_obrez', imguiJson.obrez_price, imguiJson.obrez_status},
    [43] = {'Осколок Истока', 'Осколок Истока', 'primogem', imgui.new.int(imguiJson.primogem_price), 'Цена Осколка Истока:', '##set_price_primogem', imguiJson.primogem_price, imguiJson.quest_business_status},
    [44] = {'Осколок NFT Контейнера', 'Осколок NFT Контейнера', 'oskolok_nft', imgui.new.int(imguiJson.oskolok_nft_price), 'Цена Осколка NFT:', '##set_price_oskolok_nft', imguiJson.oskolok_nft_price, imguiJson.altushka_status},
    [45] = {'Micro Tec', 'Micro Tec', 'micro_tec', imgui.new.int(imguiJson.micro_tec_price), 'Цена Micro Tec:', '##set_price_micro_tec', imguiJson.micro_tec_price, imguiJson.micro_tec_status},
    [46] = {'Золотая рулетка', 'Золотая рулетка №2 (NFT)', 'gold_r_second', imgui.new.int(imguiJson.gold_r_price), _, _, imguiJson.gold_r_price, imguiJson.nft_kont_status},
    [47] = {'Бензопила на спину', 'Бензопила на спину', 'benzopila_na_spiny', imgui.new.int(imguiJson.benzopila_price), 'Цена а/с "Бензопила на спину:"', '##set_price_benzopila_na_spiny', imguiJson.benzopila_price, imguiJson.nft_kont_status},
    [48] = {'Серебряная рулетка', 'Серебряная рулетка №2 (NFT)', 'silver_r_second', imgui.new.int(imguiJson.silver_r_price), _, _, imguiJson.silver_r_price, imguiJson.nft_kont_status},
    [49] = {'Серебро', 'Серебро', 'silver', imgui.new.int(imguiJson.silver_price), 'Цена ресурса "Серебро:"', '##set_price_silver', imguiJson.silver_price, imguiJson.nft_kont_status},
    [50] = {'Золото', 'Золото', 'gold', imgui.new.int(imguiJson.gold_price), 'Цена ресурса "Золото:"', '##set_price_gold', imguiJson.gold_price, imguiJson.nft_kont_status},
    [51] = {'Осколок предмета заточка +13', 'Осколок предмета заточка +13', 'oskolok_zatochka_nft', imgui.new.int(imguiJson.oskolok_zatochka_nft_price), 'Цена "Осколок предмета заточка +13":', '##set_price_oskolok_zatochka_nft', imguiJson.oskolok_zatochka_nft_price, imguiJson.nft_kont_status},
    [52] = {'Талон: +1 AZ Coins', 'AZ (NFT)', 'az_second', imgui.new.int(imguiJson.az), _, _, imguiJson.az, imguiJson.nft_kont_status},
    [53] = {'Сертификат Elegy', 'Сертификат т/с "Elegy"', 'nft_sert_elegy', imgui.new.int(imguiJson.nft_sert_elegy_price), 'Цена сертификата т/с "Elegy":', '##set_price_nft_sert_elegy', imguiJson.nft_sert_elegy_price, imguiJson.nft_kont_status},
    [54] = {'Сертификат Cheetah', 'Сертификат т/с "Cheetah"', 'nft_sert_cheetah', imgui.new.int(imguiJson.nft_sert_cheetah_price), 'Цена сертификата т/с "Cheetah":', '##set_price_nft_sert_cheetah', imguiJson.nft_sert_cheetah_price, imguiJson.nft_kont_status},
    [55] = {'Сертификат Картинг', 'Сертификат т/с "Картинг"', 'nft_sert_carting', imgui.new.int(imguiJson.nft_sert_carting_price), 'Цена сертификата т/с "Картинг":', '##set_price_nft_sert_carting', imguiJson.nft_sert_carting_price, imguiJson.nft_kont_status},
    [56] = {'Сертификат Phoenix', 'Сертификат т/с "Phoenix"', 'nft_sert_phoenix', imgui.new.int(imguiJson.nft_sert_phoenix_price), 'Цена сертификата т/с "Phoenix:"', '##set_price_nft_sert_phoenix', imguiJson.nft_sert_phoenix_price, imguiJson.nft_kont_status},
    [57] = {'Набор реставрации для акссесуара', 'Набор реставрации для акссесуара', 'nft_restavracia_acs', imgui.new.int(imguiJson.nft_restavracia_acs_price), '1":', '##set_price_1', imguiJson.nft_restavracia_acs_price, imguiJson.nft_kont_status},
    [58] = {'Пачка с деньгами', 'NFT-Вирты', 'nft_sa_money', _, _, _, _, _}
}

--[[ Всего в массиве menu 6 элементов
    1) Нигде не используется. Создан для читаемости
    2) Строкове значение под FarmLog[FarmData.selectedPeriod][selectedDateIndex].string . Аналогичный элемент находится в item под номером 3
    3) Дополнительное строковое значение. Используется на данный момент только для 21 элемента, так как квесты едины, я не стал разделять их на SA и AZ отдельно. Поэтому был и создан дополнительный элемент для второго строкового значения
    4) Определенный значение, получаемое во второй элемент за 1 триггер. Пример: Получили пейдей, в json пойдет payday + 1 , т.к в 4 элементе коэффициент = 1. Если коэффициент равен 0, в таком случае используется другая система выдачи
    5) Булевая переменная, внутри imguiJson . Используется для работы с чекбоксами
    6) Текст для раздела с чекбоксами для определения, какой предмет за какой чекбокс отвечает
]]

local menu = {
    [1] = {'Пейдеи', 'payday', _, 1, imguiJson.payday_status, 'Показывать полное кол-во пейдеев'},
    [2] = {'Гражданские талоны', 'grazdan_taloni', imguiJson.grazdan_taloni_price[0], 1, imguiJson.grazdan_taloni_status, 'Показывать кол-во гражданских талонов'},
    [3] = {'Зарплата', 'zarplata', _, 0, imguiJson.zarplata_status, 'Показывать зарплату'},
    [4] = {'Депозит', 'deposit', _, 0, imguiJson.deposit_status, 'Показывать депозит'},
    [5] = {'Маркетолог', 'market', imguiJson.market_price[0], 0, imguiJson.market_status, 'Показывать маркетолога'},
    [6] = {'Мидас', 'midas3slot', _, 1, imguiJson.midas3sloti_status, 'Показывать а/с "Мидас"'},
    [7] = {'Коса марси', 'kosa_marci', _, 0, imguiJson.kosa_marci_status, 'Показывать а/с "Коса Марси"'},
    [8] = {'Леший', 'leshiy', _, 2, imguiJson.leshiy_status, 'Показывать о/х "Леший"'},
    [9] = {'Маска муэрты', 'podarki_acs_ohr', _, 5, imguiJson.podarki_acs_ohr_status, 'Показывать а/с "Маска Муэрты" (ОХР)'},
    [10] = {'Анимированный огненный глаз', 'az_acs_ohr', _, 1, imguiJson.az_acs_ohr_status, 'Показывать а/с "Анимированный огненный глаз" (ОХР)'},
    [11] = {'Анимированные часы на спину', 'ribmoneta_acs_ohr', _, 1, imguiJson.ribmoneta_acs_ohr_status, 'Показывать а/с "Анимированные часы на спину" (ОХР)'},
    [12] = {'Хуйня для денег вс', 'vc_acs_ohr', _, 250, imguiJson.vc_acs_ohr_status, 'Показывать а/с "Хуйня для денег вс" (ОХР)'},
    [13] = {'Мираж', 'mirage', 'moneta_mirage', 0, imguiJson.mirage_status, 'Показывать М/П "Мираж"'},
    [14] = {'Выгодная рассрочка', 'rassrochka', _, 5, imguiJson.rassrochka_status, 'Показывать улучшение "Выгодная Рассрочка"'},
    [15] = {'Премиум Вип', 'premiumvip', _, 3, imguiJson.premiumvip_status, 'Показывать Премиум вип'},
    [16] = {'Улучшение Премиум Вип', 'premiumvipy', _, 3, imguiJson.premiumvipy_status, 'Показывать улучшение Премиум вип'},
    [17] = {'АДД Вип', 'addvip', _, 3, imguiJson.addvip_status, 'Показывать АДД Вип'}, -- default 4 element = 6
    [18] = {'Рулетки', 'total_roulette', _, 0, imguiJson.total_roulette_status, 'Показывать полное кол-во рулеток'},
    [19] = {'Ларцы', 'total_boxes', _, 0, imguiJson.total_boxes_status, 'Показывать полное кол-во ларцов'},
    [20] = {'Обрезы', 'obrez', _, 0, imguiJson.obrez_status, 'Показывать обрезы'},
    [21] = {'Квесты с бизнесов:', 'quest_business_sa', 'quest_business_az', 0, imguiJson.quest_business_status, 'Показывать квесты с бизнесов'},
    [22] = {'Финка с бизнесов:', 'finka_business', _, 0, imguiJson.finka_business_status, 'Показывать финку с бизнесов'},
    [23] = {'Финка с территорий (ЛВ)', 'finka_lv_territory', _, 0, imguiJson.finka_lv_territory_status, 'Показывать финку с территорий (ЛВ)'},
    [24] = {'Альтушка', 'altushka', _, 0, imguiJson.altushka_status, 'Показывать информацию о Альтушке'},
    [25] = {'Космическое сердце', 'space_heart', _, 0, imguiJson.space_heart_status, 'Показывать информацию о а/с "Космическое сердце"'},
    [26] = {'Micro Tec', 'micro_tec', _, 0, imguiJson.micro_tec_status, 'Показывать информацию о Micro Tec (Теки охранников)'},
    [27] = {'НФТ-Контейнеры', 'nft_kont', _, 0, imguiJson.nft_kont_status, 'Показывать информацию о НФТ-Контейнерах'}
}

function getMenuData(period, dateKey)
    local value = FarmLog[period][dateKey] or {}
    value.total_roulette = 0
    value.total_boxes = 0
    value.total_nft = 0
    
    for i = 1, 4 do
        if item[i] and value[item[i][3]] then
            value.total_roulette = value.total_roulette + (value[item[i][3]] * item[i][4][0])
        end
    end
    
    for i = 5, 34 do
        if item[i] and value[item[i][3]] then
            value.total_boxes = value.total_boxes + (value[item[i][3]] * item[i][4][0])
        end
    end

    for i = 46, 58 do
        if item[i] and value[item[i][3]] and not i == 58 then
            value.total_nft = value.total_nft + (value[item[i][3]] * item[i][4][0])
        elseif item[i] and value[item[i][3]] and i == 58 then
            value.total_nft = value.total_nft + (value[item[i][3]])
        end
    end

    return {
    [1] = {'Пейдеев: {b9ff00}' .. (value.payday or 0), 'Показывать полное кол-во пейдеев', value.payday or 0, '_'},
    [2] = {'Гражданские талоны: {b9ff00}' .. (number_separator((value.grazdan_taloni or 0) * (menu[2][3] or 0))) .. '$', 'Показывать кол-во гражданских талонов', ((value.grazdan_taloni or 0) * (menu[2][3] or 0)), 'SA'},
    [3] = {'Зарплата: {b9ff00}' .. (number_separator(value.zarplata or 0)) .. '$', 'Показывать зарплату', value.zarplata or 0, 'SA'},
    [4] = {'Депозит: {b9ff00}' .. (number_separator(value.deposit or 0)) .. '$', 'Показывать депозит', value.deposit or 0, 'SA'},
    [5] = {'Маркетолог: {b9ff00}' .. (number_separator((value.market or 0) * (item[40][7][0] or 0))) .. '$ {edff21}(' .. (value[menu[5][2]] or 0) .. ')', 'Показывать маркетолога', ((value.market or 0) * (item[40][7][0] or 0)), 'SA'},
    [6] = {'Мидас: ' .. (value.midas3slot or 0) .. ' {FFD700}AZ', 'Показывать а/с "Мидас"', value.midas3slot or 0, 'AZ'},
    [7] = {'Коса марси: ' .. (value.kosa_marci or 0) .. ' {FFD700}AZ', 'Показывать а/с "Коса Марси"', value.kosa_marci or 0, 'AZ'},
    [8] = {'Леший: ' .. (value.leshiy or 0) .. ' {FFD700}AZ', 'Показывать о/х "Леший"', value.leshiy or 0, 'AZ'},
    [9] = {'Маска Муэрты (ОХР): {b9ff00}' .. (number_separator((value.podarki_acs_ohr or 0) * (item[37][4][0] or 0))) .. '$', 'Показывать а/с "Маска Муэрты" (ОХР)', ((value.podarki_acs_ohr or 0) * (item[37][4][0] or 0)), 'SA'},
    [10] = {'Огненный глаз (ОХР): ' .. (number_separator(value.az_acs_ohr or 0)) .. ' {FFD700}AZ', 'Показывать а/с "Анимированный огненный глаз" (ОХР)', value.az_acs_ohr or 0, 'AZ'},
    [11] = {'Анимированные часы (ОХР): {b9ff00}' .. (number_separator((value.ribmoneta_acs_ohr or 0) * (item[38][4][0] or 0))) .. '$', 'Показывать а/с "Анимированные часы на спину" (ОХР)', ((value.ribmoneta_acs_ohr or 0) * (item[38][4][0] or 0)), 'SA'},
    [12] = {'Хуйня для денег вс (ОХР): {b9ff00}' .. (number_separator((value.vc_acs_ohr or 0) * (item[36][4][0] or 0))) .. '$', 'Показывать а/с "Хуйня для денег вс" (ОХР)', ((value.vc_acs_ohr or 0) * (item[36][4][0] or 0)), 'SA'},
    [13] = {'Мираж: ' .. (number_separator(value.mirage or 0)) .. ' {FFD700}AZ |{FFFFFF} Монеты Миража: {b9ff00}' .. (number_separator((value[item[39][3]] or 0) * (item[39][4][0] or 0))) .. '$ {edff21}(' .. (value[item[39][3]] or 0) .. ')', 'Показывать М/П "Мираж"', ((value.moneta_mirage or 0) * (item[39][4][0])), (value.mirage or 0), 'SA and AZ'},
    [14] = {'Выгодная рассрочка: ' .. (value.rassrochka or 0) .. ' {FFD700}AZ', 'Показывать улучшение "Выгодная Рассрочка"', value.rassrochka or 0, 'AZ'},
    [15] = {'Премиум Вип: ' .. (value.premiumvip or 0) .. ' {FFD700}AZ', 'Показывать Премиум вип', value.premiumvip or 0, 'AZ'},
    [16] = {'Улучшение премиум вип: ' .. (value.premiumvipy or 0) .. ' {FFD700}AZ', 'Показывать улучшение Премиум вип', value.premiumvipy or 0, 'AZ'},
    [17] = {'АДД Вип: ' .. (value.addvip or 0) .. ' {FFD700}AZ', 'Показывать АДД Вип', value.addvip or 0, 'AZ'},
    [18] = {'Рулетки: {b9ff00}' .. (number_separator(value.total_roulette or 0)) .. '$', 'Показать полное кол-во рулеток', value.total_roulette or 0, 'SA'},
    [19] = {'Ларцы: {b9ff00}' .. (number_separator(value.total_boxes or 0)) .. '$', 'Показать полное кол-во ларцов', value.total_boxes or 0, 'SA'},
    [20] = {'Обрезы: {b9ff00}' .. (number_separator((value.obrez or 0) * (item[42][4][0] or 0))) .. '$', 'Показать обрезы', ((value.obrez or 0) * (item[42][4][0] or 0)), 'SA'},
    [21] = {'Квесты с бизнесов: {b9ff00}' .. (number_separator((value.quest_business_sa or 0))) .. '$ | {FFFFFF}' .. (value.quest_business_az or 0) .. '{FFD700} AZ', 'Показать квесты с бизнесов', ((value.quest_business_sa or 0)), (value.quest_business_az or 0), 'SA and AZ'},
    [22] = {'Финка с бизнесов: {b9ff00}' .. (number_separator(value.finka_business or 0)) .. '$', 'Показать финку с бизнесов', (value.finka_business or 0), 'SA'},
    [23] = {'Финка с территорий (ЛВ): {b9ff00}' .. (number_separator(value.finka_lv_territory or 0)) .. '$', 'Показать финку с территорий (ЛВ)', (value.finka_lv_territory or 0), 'SA'},
    [24] = {'Альтушка: {b9ff00}' .. (number_separator(value.altushka or 0)) .. '$', 'Показать Альтушку', (value.altushka or 0), 'SA'},
    [25] = {'Космическое сердце: {b9ff00}' .. (number_separator(value.space_heart or 0)) .. '$', 'Показать а/с "Космическое сердце"', (value.space_heart or 0), 'SA'},
    [26] = {'Micro Tec: {b9ff00}' .. (number_separator((value.micro_tec or 0) * (item[45][4][0] or 0))) .. '$', 'Показывать Micro Tec (Теки охранников)', (value.micro_tec or 0), 'SA'},
    [27] = {'НФТ-Контейнеры: {b9ff00}' .. (number_separator(value.total_nft or 0)) .. '$ | {FFFFFF}' .. (value.az_second or 0) .. '{FFD700} AZ', 'Показывать НФТ-Контейнеры', (value.total_nft or 0), (value.az_second or 0), 'SA and AZ'}
    }
end

local renderWindow = imgui.new.bool(false)
local debugWindow = imgui.new.bool(false)
local thirdWindow = imgui.new.bool(false)
local radio_button_bool = imgui.new.bool(false)
local period = FarmData.selectedPeriod
local HasBusinessDialogOpened = false
local status_rec = false
local status_among_us = false
local cashedCheckboxTexts = {}
local nop_token = false
local biz_money = 0
local getBusinessDialog = false
local user_nickname = ''
local current_payday_multiplier = 2 -- Изначально всегда будет x2, потому что если у тебя есть х2 дом/ты подселен - в пакет с худом и прочей инфой не прилетает информация о том, что у тебя как раз-таки х2 пейдеи. С х3 и х4 проблемы нет
--[[ Что увеличивается в зависимости от множителя?
1) АДД Вип - по описанию 3 аз в пейдей. При х4 - 12 AZ
2) Премиум Вип - по описанию 2 аз в пейдей. При х4 - 6 AZ . Почему так?
--]]

function add_loot(loot, value)
    local currentDate = os.date('%d.%m.%y')
    local currentWeek = getWeekRange(currentDate)
    local currentMonth = formatDate()
    if FarmLog.days[currentDate] == nil then
        FarmLog.days[currentDate] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
    end
    if FarmLog.weeks[currentWeek] == nil then
        FarmLog.weeks[currentWeek] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
    end
    if FarmLog.months[currentMonth] == nil then
        FarmLog.months[currentMonth] = {current_editing = '', sa = 0, az = 0, vc = 0, nft_sa_money = 0, nft_restavracia_acs = 0, nft_sert_phoenix = 0, nft_sert_carting = 0, nft_sert_cheetah = 0, nft_sert_elegy = 0, az_second = 0, oskolok_zatochka_nft = 0, gold = 0, silver = 0, silver_r_second = 0, benzopila_na_spiny = 0, gold_r_second = 0, micro_tec = 0, space_heart = 0, altushka = 0, finka_lv_territory = 0, quest_business_sa = 0, quest_business_az = 0, finka_business = 0, primogem = 0, second_hand_box = 0, minecraft_box = 0, gentleman_box = 0, marvel_box = 0, super_moto_box = 0, super_auto_box = 0, rare_blue_box = 0, rare_red_box = 0, rare_yellow_box = 0, nostalgic_box = 0, fortnite_box = 0, organization_box = 0, oligarch_box = 0, random_box = 0, mortal_combat_box = 0, custom_accessories_box = 0, crafter_box = 0, treasure_hunter_box = 0, fisher_box = 0, products_carrier_box = 0, total_boxes = 0, total_roulette = 0, total_business = 0, obrez = 0, kosa_marci = 0, bitcoin = 0, midas3slot = 0,  grazdan_taloni = 0, concept_car_luxury_box = 0, larec_premiya = 0, super_car_box = 0, bronze_r = 0, silver_r = 0, gold_r = 0, platinum_r = 0, moneta_mirage = 0, leshiy = 0, podarki_acs_ohr = 0, az_acs_ohr = 0, ribmoneta_acs_ohr = 0, vc_acs_ohr = 0, payday = 0, zarplata = 0, deposit = 0, mirage = 0, market = 0, rassrochka = 0, premiumvip = 0, premiumvipy = 0, addvip = 0}
    end

    FarmLog.days[currentDate][loot] = FarmLog.days[currentDate][loot] + value
    FarmLog.weeks[currentWeek][loot] = FarmLog.weeks[currentWeek][loot] + value
    FarmLog.months[currentMonth][loot] = FarmLog.months[currentMonth][loot] + value
    FarmLogTimer()
end

function sampEvents.onServerMessage(color, message)
    if message:find('______________________________Банковский чек______________________________') and not message:find('%[%d+%]') then -- Определение по пейдею, включает в себя дополнительно несколько переменных ниже
        if select(1, sampGetCurrentServerAddress()) == '80.66.82.147' then -- Айпи VC (Тут вероятно все множители неправильные и их надо переделывать, дополнительный элемент подмассива создавать)
            for i in pairs(menu) do
                if menu[i][4] ~= 0 and menu[i][5][0] == true then
                    add_loot(menu[i][2], menu[i][4])
                end
            end

            local current_minute = tonumber(os.date("%M"))
            sampAddChatMessage('Получили минуты для косы марси: ' .. tostring(current_minute)) -- в tostreing на всякий
            print('Получили минуты для косы марси: ' .. current_minute)
            if current_minute == 59 or current_minute == 0 then
                sampAddChatMessage('Прошли условие по 0 минуте', -1)
                print('Прошли условие по 0 минуте')
                add_loot(menu[7][2], 2)
            end

        else -- Айпи не Вайс-Сити 
            for i in pairs(menu) do
                if menu[i][4] ~= 0 and menu[i][5][0] == true then
                    add_loot(menu[i][2], menu[i][4])
                end
            end

            local current_minute = tonumber(os.date("%M"))
            sampAddChatMessage('Получили минуты для косы марси: ' .. tostring(current_minute)) -- в tostreing на всякий
            print('Получили минуты для косы марси: ' .. current_minute)
            if current_minute == 59 or current_minute == 0 then
                sampAddChatMessage('Прошли условие по 0 минуте', -1)
                print('Прошли условие по 0 минуте')
                add_loot(menu[7][2], 2)
            end

            --add_loot()
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    --if message:find("%[Операция Мираж%] {......}Поздравляем! Вы заняли {......}#%d+ место{......}! Заработав: {......}%d+ AZ Coins{......}.") then -- [Операция Мираж] {FFFFFF}Поздавляем! Вы заняли {FFD700}#1 место{ffffff}! Заработав: {ae433d}666 AZ Coins{ffffff}.
    if message:find('^%[Операция Мираж%] {......}Поздравляем! Вы заняли {......}#%d+ место{......}! Заработав: {......}(%d+) AZ Coins{......}.') and not message:find('%[%d+%]') then
        if menu[13][5][0] then -- Статус: Неизвестно ?
            local mirage_az = message:match('^%[Операция Мираж%] {......}Поздравляем! Вы заняли {......}#%d+ место{......}! Заработав: {......}(%d+) AZ Coins{......}.')
            add_loot(menu[13][2], mirage_az) -- Мираж
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^Общая заработная плата: %$(%d+[.,]?%d+[.,]?%d+)') and not message:find('%[%d+%]') then -- Зарплата
        if menu[3][5][0] then -- Статус: Считает успешно ?
            local zarplata_sa = message:match('Общая заработная плата: %$(%d+[.,]?%d+[.,]?%d+)') -- Общая заработная плата: $2,107,850
            add_loot(menu[3][2], removeSeparator(zarplata_sa)) -- Зарплата
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^Текущая сумма на депозите: %$(%d*[.,]?%d+[.,]?%d+) %{......%}(.*)%$(%d*[.,]?%d+[.,]?%d+)') and not message:find('%[%d+%]') then -- Депозит
        if menu[4][5][0] then -- Статус: Считает успешно ?
            local _, deposit_i2 = message:match('(.*)%$(%d+[.,]?%d+[.,]?%d+)')
            add_loot(menu[4][2], removeSeparator(deposit_i2)) -- Депозит
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^{......}%[Реклама Бизнеса%] Объявление: (.-) Отправил: ' .. user_nickname .. '') then --{FCAA4D}[Реклама Бизнеса] Объявление: Работает б/з "Аммуниция" №136. У нас лучшие боеприпасы. Отправил: Aron_Stealer[490]
        if menu[5][5][0] then -- Статус: Считает успешно !
            add_loot(menu[5][2], 1) -- Маркет
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^%[Информация%] {......}Вы использовали сундук с рулетками и получили') and not message:find('%[%d+%]') then -- Подсчет всех рулеток (Бронзовая, серебряная, золотая, платиновая). Сундуки: Обычный (при регистрации), Донатный
        local drop_starter_and_donate_boxes = message:match('Вы использовали сундук с рулетками и получили (.+)!') -- Статус: Неизвестно ?
        if menu[18][5][0] then
            for i in pairs(item) do
                if item[i][2] == drop_starter_and_donate_boxes then
                    add_loot(item[i][3], 1)
                    drop_starter_and_donate_boxes = nil
                end
            end
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    if message:find('^%[Информация%] {......}Вы использовали платиновый сундук с рулетками и получили') and not message:find('%[%d+%]') then -- Подсчет всех рулеток (Бронзовая, серебряная, золотая, платиновая). Сундуки: Платиновый
        local drop_platinum_box = message:match('Вы использовали платиновый сундук с рулетками и получили (.+)!') -- Статус: Неизвестно ?
        if menu[18][5][0] then
            for i in pairs(item) do
                if item[i][2] == drop_platinum_box then
                    add_loot(item[i][3], 1)
                    drop_platinum_box = nil
                end
            end
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    if message:find('%[Информация%] {......}Вы использовали тайник Илона Маска и получили') and not message:find('%[%d+%]') then -- Статус: Неизвестно ?
        local drop_elon_musk_box = message:match('Вы использовали тайник Илона Маска и получили (.+)!')
        if menu[19][5][0] then
            for i in pairs(item) do
                if item[i][2] == drop_elon_musk_box then
                    add_loot(item[i][3], 1)
                    drop_elon_musk_box = nil
                end
            end
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    --if message:find('^Вы открыли Тайник Лос Сантоса!') or message:find('^Вы открыли Тайник Vice City!') and not message:find('%[%d+%]') then
    if message:find('^%[Информация%] {......}Получено: .+ и .+!$') then
        local drop_ls_vc_1_box, drop_ls_vc_2_box = message:match('%[Информация%] {......}Получено: (.+) и (.+)!$')
        if menu[19][5][0] then
            for i in ipairs(item) do
                if item[i][2] == drop_ls_vc_1_box then
                    add_loot(item[i][3], 1)
                    drop_ls_vc_1_box = nil
                end
                if item[i][2] == drop_ls_vc_2_box then
                    add_loot(item[i][3], 1)
                    drop_ls_vc_2_box = nil
                end
            end
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    if message:find('^Вы открыли Тайник Собирателя!') and not message:find('%[%d+%]') then
        local drop_sobiratel_box = message:match('Получено: (.+)!')
        if menu[19][5][0] then
            for i in pairs(item) do
                if item[i][2] == drop_sobiratel_box then
                    add_loot(item[i][3], 1)
                    drop_sobiratel_box = nil
                end
            end
        end
        FarmLogTimer()
        imguiJsonTimer()
    end

    if message:find('^%[Операция Мираж%] {......}Вы заработали {......}%d+ монет миража') and not message:find('%[%d+%]') then
        if menu[13][5][0] then
            local moneta_mirage_local = message:match('Вы заработали {FFD700}(%d+) монет миража')
            add_loot(item[39][3], moneta_mirage_local) -- Монета миража
            FarmLogTimer()
            imguiJsonTimer()
        end
    end 

    if message:find('%[Информация%] {......}Вы использовали запас обрезов.') and not message:find('%[%d+%]') then
        if menu[20][5][0] then
            add_loot(item[42][3], 20) -- Обрез (20 штук)
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^С объезда территорий вы заработали семейные монеты%(%d+ шт%) и деньги: %$(.-)%.$') then
        if menu[23][5][0] then
            local finka_lv_territory_money = message:match('деньги: %$(%d+[.,]?%d+[.,]?%d+)')
            finka_lv_territory_money = removeSeparator(finka_lv_territory_money)
            print(removeSeparator(finka_lv_territory_money))
            add_loot(menu[23][2], removeSeparator(finka_lv_territory_money))
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('^Вы получили (.-)%$(%d+[.,]?%d+[.,]?%d+) от хар%-ки надетого аксессуара Космическое сердце %(выдается каждые 30 минут%)$') and not message:find('%[%d+%]') then
        if menu[25][5][0] then
            local _, space_heart_money = message:match('Вы получили (.-)%$(%d+[.,]?%d+[.,]?%d+)')
            add_loot(menu[25][2], removeSeparator(space_heart_money))
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('Вы получили (.*) от хар%-ки надетого аксессуара Космическое сердце %(выдается каждые 30 минут%)') and not message:find('%[%d+%]') then
        if menu[25][5][0] then
            local space_heart_larec = message:match('Вы получили (.*) от хар%-ки надетого аксессуара Космическое сердце %(выдается каждые 30 минут%)')
            for i in pairs(item) do
                if item[i][2] == space_heart_larec then
                    add_loot(menu[25][2], item[i][7][0])
                    space_heart_larec = nil
                    FarmLogTimer()
                    imguiJsonTimer()
                end
            end
        end
    end

    if message:find("Вам был добавлен предмет :item6368:. Откройте инвентарь, используйте клавишу 'Y' или /invent") and not message:find('%[%d+%]') then -- Micro Tec (18 шт)
        if menu[26][5][0] then
            add_loot(menu[26][2], 18)
            FarmLogTimer()
            imguiJsonTimer()
        end
    end

    if message:find('%[Информация%] {FFFFFF}Вы успешно сняли деньги со счета. Остаток: %$(.*)') and biz_money ~= 0 and not HasBusinessDialogOpened then --[Информация] {FFFFFF}Вы успешно сняли деньги со счета. Остаток: $16,790,789
        add_loot(menu[22][2], tonumber(biz_money) or 0)
        biz_money = 0
        FarmLogTimer()
        imguiJsonTimer()
    end

    if message:find("Вам был добавлен предмет Bitcoin %(BTC%). Откройте инвентарь, используйте клавишу 'Y' или /invent") then
        sampAddChatMessage('Поймали', -1)
    end
end

function sampEvents.onShowDialog(id, style, title, button1, button2, text) -- Для финки бизнесов
    if id == 159 and style == 1 and text:find('{ffffff}Баланс бизнеса' and '{ffffff}Введите сумму, которую хотите снять:' and '{ff0000}Сумма будет зачислена на ваш банковский счёт.' and '{cccccc}ВАЖНО:') then
        HasBusinessDialogOpened = true
    end
    if text:find('{ffffff}Баланс бизнеса%: {ffff00}%$(%d+[.,]?%d+[.,]?%d+)') and getBusinessDialog then
        local business_money = text:match('{ffffff}Баланс бизнеса%: {ffff00}%$(%d+[.,]?%d+[.,]?%d+)')
        business_money = removeSeparator(business_money)
        if (tonumber(business_money)) ~= nil or (tonumber(business_money)) ~= 0 then
            sampSendDialogResponse(id, 1, 0, tonumber(business_money) or 0)
            add_loot(menu[22][2], tonumber(business_money) or 0) 
            getBusinessDialog = false
            return false
        end
    end
end

function sampEvents.onSendDialogResponse(dialogId, button, listboxId, input) -- Для финки бизнесов
    if dialogId == 159 and menu[22][5][0] and HasBusinessDialogOpened then
        biz_money = input
        HasBusinessDialogOpened = false
        input = 0
    end
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil

    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true

    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    imgui.GetIO().Fonts:Clear()
    imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/EagleSans Regular Regular.ttf', 16.0, nil, glyph_ranges)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('regular'), 18, config, iconRanges)

    SoftBlueTheme()
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 900, 530
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        if imgui.Begin(u8'Farm log', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then

            imgui.BeginChild('##menuChild', imgui.ImVec2(200, 400), true)
            imgui.SetCursorPosX(40) -- Центрирование переключателя
                if imgui.ArrowButton("##left", imgui.Dir.Left) then
                    if period == "weeks" then period = "days"
                    elseif period == "months" then period = "weeks"
                    else period = "months" end
                    end
                
                    imgui.SameLine()
                    imgui.Text(u8(tostring(period):upper())) -- Текущий период
                    imgui.SameLine()
                
                    if imgui.ArrowButton("##right", imgui.Dir.Right) then
                        if period == "days" then period = "weeks"
                        elseif period == "weeks" then period = "months"
                        else period = "days" end
                    end
                
                    imgui.Separator() -- Разделитель под переключателем

                    if period == 'days' then
                        local tkeys = {}
                        for k in pairs(FarmLog.days) do 
                            table.insert(tkeys, k) 
                        end
    
                        table.sort(tkeys, function(a, b)
                            local d, m, y = a:match('(%d+).(%d+).(%d+)')
                            local d2, m2, y2 = b:match('(%d+).(%d+).(%d+)')
        
                            -- Преобразуем в числа и сравниваем как даты
                            local date1 = os.time({day = tonumber(d), month = tonumber(m), year = 2000 + tonumber(y)})
                            local date2 = os.time({day = tonumber(d2), month = tonumber(m2), year = 2000 + tonumber(y2)})
        
                            return date1 > date2  -- Сортируем от новых к старым
                        end)
    
                        for _, k in ipairs(tkeys) do
                            if imgui.CenterButton(k, 30) then
                                FarmData.selectedDateIndex = k
                                FarmData.selectedPeriod = 'days'
                            end
                        end
                    elseif period == 'weeks' then
                        for key, _ in pairs(FarmLog.weeks) do
                                if imgui.CenterButton(key, 30) then
                                    FarmData.selectedDateIndex = key
                                    FarmData.selectedPeriod = 'weeks'
                                end
                            end
                    elseif period == 'months' then
                        for key, _ in pairs(FarmLog.months) do
                            if imgui.CenterButton(key, 30) then
                                FarmData.selectedDateIndex = key
                                FarmData.selectedPeriod = 'months'
                            end
                        end
                    end
            imgui.EndChild()
            
            imgui.SameLine()
            imgui.BeginChild("##logs", imgui.ImVec2(660, 400), true)
            -- Вывод информации
            if FarmData.selectedDateIndex and FarmData.selectedPeriod then
                local menuData = getMenuData(FarmData.selectedPeriod, FarmData.selectedDateIndex)
                for j, data in ipairs(menuData) do
                    if data and data[1] and menu[j][5][0] then
                        imgui.TextColoredRGB(u8(data[1]))
                        if imgui.IsItemClicked() and data[1] == 'Рулетки: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_roulette or 0)) .. '$' then
                            sampAddChatMessage('Это у нас: ' .. data[1], -1)
                            imgui.OpenPopup(u8'Подробная статистика | Рулетки')
                        end
                        if imgui.IsItemClicked() and data[1] == 'Ларцы: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_boxes or 0)) .. '$' then
                            sampAddChatMessage('Это у нас: ' .. data[1], -1)
                            imgui.OpenPopup(u8'Подробная статистика | Ларцы')
                        end
                        if imgui.IsItemClicked() and data[1] == 'НФТ-Контейнеры: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_nft or 0)) .. '$ | {FFFFFF}' .. (FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].az_second or 0) .. '{FFD700} AZ' then
                            sampAddChatMessage('Это у нас: ' .. data[1], -1)
                            imgui.OpenPopup(u8('Подробная статистика | НФТ-Контейнеры'))
                        end
                        --imgui.ShowHint(u8'Посмотреть подробную статистику рулеток?')
                        if imgui.IsItemHovered() and data[1] == 'Рулетки: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_roulette or 0)) .. '$' then
                            --print((number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_roulette or 0)))
                            imgui.BeginTooltip()
                            imgui.Text(u8'Посмотреть подробную статистику рулеток?')
                            imgui.EndTooltip()
                        end
                        if imgui.IsItemHovered() and data[1] == 'Ларцы: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_boxes or 0)) .. '$' then
                            imgui.BeginTooltip()
                            imgui.Text(u8'Посмотреть подробную статистику ларцов?')
                            imgui.EndTooltip()
                        end
                        if imgui.IsItemHovered() and data[1] == 'НФТ-Контейнеры: {b9ff00}' .. (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].total_nft or 0)) .. '$ | {FFFFFF}' .. (FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].az_second or 0) .. '{FFD700} AZ' then
                            imgui.BeginTooltip()
                            imgui.Text(u8'Посмотреть подробную статистику НФТ-Контейнеров?')
                            imgui.EndTooltip()
                        end
                    end
                end
                imgui.SameLine()
            end

            imgui.SetNextWindowSize(imgui.ImVec2(600, 250), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(u8'Подробная статистика | Рулетки', _, imgui.WindowFlags.NoResize) then
                local value = FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex] or {}
                imgui.Columns(3)
                imgui.SetColumnWidth(-1, 245.0)
                imgui.Text(u8'Предмет')
                imgui.NextColumn()
                imgui.SetColumnWidth(-1, 175.0)
                imgui.Text(u8'Цена за единицу')
                imgui.NextColumn()
                imgui.Text(u8'Общее кол-во виртов')
                imgui.Columns(1)
                imgui.Separator()
                for i = 1, 4 do
                    if value[item[i][3]] and item [i][1] and item[i][7][0] then
                        imgui.Columns(3)
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. item[i][1] .. ': {b9ff00}' .. value[item[i][3]] .. '{FFFFFF} шт'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. number_separator(item[i][7][0]) .. '{b9ff00}$'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8(('{FFFFFF}' .. number_separator((value[item[i][3]]) * (item[i][7][0]))) .. '{b9ff00}$'))
                        imgui.Columns(1)
                        imgui.Separator()
                    end
                end
                if imgui.Button(u8'Закрыть', imgui.ImVec2(imgui.GetWindowWidth() - 30, 30)) then
                    imgui.CloseCurrentPopup()
                end
            end

            imgui.SetNextWindowSize(imgui.ImVec2(600, 860), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(u8'Подробная статистика | Ларцы', _, imgui.WindowFlags.NoResize) then
                local value = FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex] or {}
                imgui.Columns(3)
                imgui.SetColumnWidth(-1, 245.0)
                imgui.Text(u8'Предмет')
                imgui.NextColumn()
                imgui.SetColumnWidth(-1, 175.0)
                imgui.Text(u8'Цена за единицу')
                imgui.NextColumn()
                imgui.Text(u8'Общее кол-во виртов')
                imgui.Columns(1)
                imgui.Separator()
                for i = 5, 34 do
                    if value[item[i][3]] and item[i][1] and item[i][7][0] then
                        imgui.Columns(3)
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. item[i][1] .. ': {b9ff00}' .. value[item[i][3]] .. '{FFFFFF} шт'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. number_separator(item[i][7][0]) .. '{b9ff00}$'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8(('{FFFFFF}' .. number_separator((value[item[i][3]]) * (item[i][7][0]))) .. '{b9ff00}$'))
                        imgui.Columns(1)
                        imgui.Separator()
                    end
                end
                if imgui.Button(u8'Закрыть', imgui.ImVec2(imgui.GetWindowWidth() - 30, 30)) then
                    imgui.CloseCurrentPopup()
                end
            end

            imgui.SetNextWindowSize(imgui.ImVec2(600, 540), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(u8'Подробная статистика | НФТ-Контейнеры', _, imgui.WindowFlags.NoResize) then
                local value = FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex] or {}
                imgui.Columns(3)
                imgui.SetColumnWidth(-1, 245.0)
                imgui.Text(u8'Предмет')
                imgui.NextColumn()
                imgui.SetColumnWidth(-1, 175.0)
                imgui.Text(u8'Цена за единицу')
                imgui.NextColumn()
                imgui.Text(u8'Общее кол-во виртов')
                imgui.Columns(1)
                imgui.Separator()
                for i = 46, 58 do
                    if i ~= 58 and value[item[i][3]] and item[i][1] and item[i][7][0] then
                        imgui.Columns(3)
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. item[i][1] .. ': {b9ff00}' .. value[item[i][3]] .. '{FFFFFF} шт'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. number_separator(item[i][7][0]) .. '{b9ff00}$'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8(('{FFFFFF}' .. number_separator((value[item[i][3]]) * (item[i][7][0]))) .. '{b9ff00}$'))
                        imgui.Columns(1)
                        imgui.Separator()
                    elseif i == 58 and value[item[i][3]] and item[i][1] then
                        imgui.Columns(3)
                        imgui.TextColoredRGB(u8('{FFFFFF}' .. item[i][1] .. ':'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8('-'))
                        imgui.NextColumn()
                        imgui.TextColoredRGB(u8(('{FFFFFF}' .. number_separator(value[item[i][3]]) .. '{b9ff00}$')))
                        imgui.Columns(1)
                        imgui.Separator()
                    end
                end
                if imgui.Button(u8'Закрыть', imgui.ImVec2(imgui.GetWindowWidth() - 30, 30)) then
                    imgui.CloseCurrentPopup()
                end
            end

            imgui.EndChild()

            imgui.BeginChild('##stats', imgui.ImVec2(200, 55), true)
                if imgui.Button(faicons("GEAR"), imgui.ImVec2(50, 25)) then
                    imgui.OpenPopup(u8'Настройки')
                end
                imgui.ShowHint(u8'Настройки')

                imgui.SameLine()
                if imgui.Button(faicons("CIRCLE_TRASH"), imgui.ImVec2(50, 25)) then
                    for key, _ in pairs(FarmLog[FarmData.selectedPeriod]) do
                        if FarmData.selectedDateIndex == key then
                            sampAddChatMessage('До')
                            FarmLog[FarmData.selectedPeriod][key] = nil
                            FarmLog()
                            break
                        end
                    end
                end
                imgui.ShowHint(u8'Удалить текущий лог')

                imgui.SameLine()
                if imgui.Button(faicons("CIRCLE_USER"), imgui.ImVec2(50, 25)) then
                    imgui.OpenPopup(u8'О скрипте')
                end
                imgui.ShowHint(u8'О скрипте')

                imgui.SetNextWindowSize(imgui.ImVec2(600, 860), imgui.Cond.FirstUseEver)
                if imgui.BeginPopupModal(u8'Настройки', _, imgui.WindowFlags.NoResize) then
                    if imgui.BeginTabBar('Tabs') then -- задаём начало вкладок
                        if imgui.BeginTabItem(u8'Checkbox вкладка') then -- первая вкладка
                            for i, data in ipairs(menu) do
                                if data and data[5] then
                                    if imgui.Checkbox(cashedCheckboxTexts[i], data[5]) then
                                        imguiJson()
                                    end
                                end
                            end
                            imgui.EndTabItem() -- конец вкладки
                        end
                        if imgui.BeginTabItem(u8'Input вкладка') then -- вторая вкладка
                            imgui.Text(u8'Поиск предмета:')
                            FarmData.search_filter:Draw('##searchFilterr', 562) -- default 562
                            imgui.BeginChild('##stats', imgui.ImVec2(575, 650), true)
                            for k, _ in ipairs(item) do
                                if item[k][1] and item[k][7] and (item[k][8]) then
                                    if item[k][8][0] then
                                        if FarmData.search_filter:PassFilter(u8(item[k][1])) then
                                            if imgui.Button(u8('Предмет: ' .. item[k][1] .. ' | Цена: ' .. number_separator(item[k][7][0]) .. '$')) then
                                                FarmData.current_editing = item[k][3] -- zaebis
                                                sampAddChatMessage(FarmData.current_editing, -1)
                                                FarmData.input_price = item[k][7] -- zaebis second
                                                sampAddChatMessage(tostring(FarmData.input_price[0]), -1)
                                            end
                                            imgui.NextColumn()
                                            imgui.Columns(1)
                                            imgui.Separator()
                                        end
                                    end
                                end
                            end
                            imgui.EndChild()
                            imgui.SetNextItemWidth(262) -- default 562
                            if imgui.InputInt(u8('##priceInput'), FarmData.input_price, 0, 0) then
                                if not (FarmData.current_editing == '') then

                                    for _, array_data in pairs(item) do
                                        if array_data[3] == FarmData.current_editing then
                                            array_data[5] = tonumber(FarmData.input_price[0])
                                        end
                                    end
                                    FarmLogTimer()
                                    imguiJsonTimer()
                                end
                            end

                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem(u8'Arz-Market вкладка') then -- третья вкладка
                            imgui.Text(u8('Это вкладка для парсинга данных со статистики арз-маркета'))
                            if imgui.RadioButtonBool('Radio Button', radio_button_bool[0]) then
                                radio_button_bool[0] = not radio_button_bool[0]
                            end
                            imgui.EndTabItem() 
                        end
                        

                        imgui.Separator()
                        if imgui.Button(u8'Закрыть', imgui.ImVec2(562, 30)) then
                            imgui.CloseCurrentPopup()
                            imguiJson()
                        end
                    end
                end

                if imgui.BeginPopupModal(u8'О скрипте', _, imgui.WindowFlags.NoResize) then
                    imgui.Text(u8'Основной функционал взят со скриптов:') imgui.SameLine() imgui.Link('https://www.blast.hk/members/209662/', u8'Неадекватная сова')
                    imgui.Text(u8'Версия: ' .. thisScript().version)
                    imgui.Text(u8'Внимание! Скрипт считает за х2 пейдей, если у вас не х2 - соответственно подсчёт будет неправильный.')
                    if imgui.Button(u8'Закрыть', imgui.ImVec2(imgui.GetWindowWidth() - 30, 30)) then
                        imgui.CloseCurrentPopup()
                    end
                end

            imgui.EndChild()
            

            imgui.SameLine()
            local menuData = getMenuData(FarmData.selectedPeriod, FarmData.selectedDateIndex)
            local totalAZ = 0
            local totalSA = 0
            for _, data in ipairs(menuData) do
                if data and data[4] == 'AZ' then
                    totalAZ = totalAZ + (data[3] or 0)
                elseif data and data[4] == 'SA' then
                    totalSA = totalSA + (data[3] or 0)
                elseif data and data[5] == 'SA and AZ' or 'AZ and SA' then
                    totalAZ = totalAZ + (tonumber(data[4]) or 0)
                    totalSA = totalSA + (data[3] or 0)
                end
            end
            if FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex] then
                FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].az = totalAZ
                FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].sa = totalSA
            end
            imgui.TextColoredRGB(u8(('Получено за %s: {b9ff00}SA %s$ | {FFD700}AZ %s | {FFA500}Общее %s$'):format((FarmData.selectedDateIndex), number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].sa), (FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].az), (number_separator(FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].sa + (FarmLog[FarmData.selectedPeriod][FarmData.selectedDateIndex].az * imguiJson.az[0])))))) --SA+AZ 
            imgui.SameLine()
            imgui.NewLine()
            imgui.SetCursorPosX(223)
        end
    end
)

function main()
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage('{b9ff00}[Farm {FFD700}log]{77DDE7} Успешная загрузка. Команда для активации: {42AAFF}/flog', -1)

    user_nickname = (sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(1))))

    for i, data in ipairs(menu) do
        if data and data[6] then
            cashedCheckboxTexts[i] = u8(data[6])
        end
    end

    sampRegisterChatCommand('flog', function()
        renderWindow[0] = not renderWindow[0]
    end)

    while true do
        wait(0)
    end
end

addEventHandler("onReceivePacket", function(id, bs)
    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        local cefPacketID = raknetBitStreamReadInt8(bs)
        if cefPacketID == 17 then
            raknetBitStreamIgnoreBits(bs, 32)
            local length = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            local cmd = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
            
            local eventCall, dataCall = string.match(cmd, "window%.executeEvent%('([%w.]+)', `(.*)`%)")

            if eventCall == 'event.pubg.updateMatchStartingText' and cmd:find('"Все готовы! Матч начнётся через') then
                if status_rec then
                    sampAddChatMessage('[Farm Log] Идет подготовка к мероприятию "Мираж". Кое-что было автоматически отключено!', -1)
                    status_rec = false
                end
            end
            if cmd:find('event.api.setToken') and nop_token then
               sampAddChatMessage('Пакет с токеном найден', -1)
               return false
            end
            if cmd:find('Вы зарегистрировались на: Фабрика Желаний.') then
                status_among_us = false
                sampAddChatMessage('Мы зарегистрировались! Отменяем отправку пакетов')
                sendTelegramNotification('Мы зарегистрировались! Отменяем отправку пакетов')
            end
            if eventCall == 'event.business.info.initializeMenuTabs' and cmd:find('Управление бизнесом') then
                --sampAddChatMessage('Ура')
                evalanon(JS)
            end
            if eventCall == 'cef.modals.showModal' and cmd:find('"Задания для бизнесов"' and 'Вы успешно забрали награду за задание') then

                --[[
                    Отображается все корректно, как и должно быть. Поэтому мы меняем старый метод получения наград на новый, который учитывает тип огонька.
                    (Собственно, просто хукает конкретные значения)
                ]]

                local finka = dataCall:match('%+ %$ (%d+) в финку') 
                local nalom_money = dataCall:match('%+ %$ (%d+) вирт') 
                local nalom_az = dataCall:match('%+(%d+) AZ Coins') 
                local number_primogem = dataCall:match('%+(%d+) Осколок Истока')
                --sampAddChatMessage('Хукнули награду! Подробнее в print', -1)
                --print(finka .. ' | ' .. nalom_money .. ' | ' .. nalom_az .. ' | ' .. number_primogem)
                add_loot(item[43][3], tonumber(number_primogem or 0)) -- Добавление самого осколка истока в переменную primogem
                add_loot(menu[21][2], item[43][4][0]) -- Добавление осколка истока (Цена) [Почему у нас такая реализация?]
                add_loot(menu[21][3], tonumber(nalom_az or 0)) -- AZ
                add_loot(menu[21][2], tonumber(nalom_money or 0))
                add_loot(menu[21][2], tonumber(finka or 0))
            end
            if eventCall == 'containerContent.initialize' then -- Полностью работоспособен. Проверено на 3 тайниках. Думаю этого хватит. Насчет Супер-НФТ контейнер не понятно. Вероятно, там структура пакета может отличаться
                if imguiJson.flag_nft then
                    return
                end

                sampAddChatMessage('Нашли, хоба', -1)
                if dataCall:find('"items":%[') and not imguiJson.flag_nft then
                    imguiJson.flag_nft = true
                    local items_info = dataCall:match('"items":%[(.*)%]')

                    if items_info then
                        for main_item in items_info:gmatch('{([^}]+)}') do
                            local item_name = main_item:match('"title":"([^"]+)"')
                            local count_item = main_item:match('"count":(%d+)')

                            if item_name and count_item then
                                item_name = item_name:gsub('\\"', '"')
                                count_item = tonumber(count_item)
                                sampAddChatMessage(string.format('Предмет: %s | Количество: %d', item_name, count_item), -1)
                                for i, _ in pairs(item) do
                                    if item[i][1] == item_name and item[i][3] then
                                        add_loot(item[i][3], tonumber(count_item or 0))
                                        sampAddChatMessage('Да')
                                    end
                                end
                            end
                        end
                    end
                    lua_thread.create(function()
                        wait(500)
                        imguiJson.flag_nft = false
                    end)
                end
                imguiJsonTimer()
            end

            if eventCall == 'event.arizonahud.serverInfo' and dataCall:find([["multiplier":%d+]]) then
                local packet_multiplier = dataCall:match([["multiplier":(%d+)]])
                if packet_multiplier then 
                    imguiJson.current_payday_multiplier = packet_multiplier
                    imguiJson()
                    sampAddChatMessage(imguiJson.current_payday_multiplier)
                end
            end
        end
    end
end)
    
addEventHandler('onSendPacket', function(id, bs, priority, reliability, orderingChannel)
    if id == 220 then
        local id = raknetBitStreamReadInt8(bs)
        local packettype = raknetBitStreamReadInt8(bs)
        local strlen = raknetBitStreamReadInt16(bs)
        local text = raknetBitStreamReadString(bs, strlen)
        if packettype ~= 0 and packettype ~= 1 and #text > 2 then
            if text:find('business_take_all_money|true') then
                sendCef('business.info.widthdraw')
                getBusinessDialog = true
            end
        end
    end
end)

function emulCef(str, is_encoded)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteInt8(bs, is_encoded and 1 or 0)
    if is_encoded then
        raknetBitStreamEncodeString(bs, str)
    else
        raknetBitStreamWriteString(bs, str)
    end
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end

function evalanon(code)
    emulCef(('(() => {%s})();'):format(code))
end

function imgui.Link(link, text)
    text = text or link
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local col = { 0xFFFF7700, 0xFFFF9900 }
    if imgui.InvisibleButton("##" .. link, tSize) then os.execute("explorer " .. link) end
    local color = imgui.IsItemHovered() and col[1] or col[2]
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

function removeSeparator(text)
    return string.gsub(text, "[,.]", "")
end

function number_separator(n) 
	local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function imgui.ShowHint(description)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.CenterButton(text, sizeY)
    return imgui.Button(u8(text), imgui.ImVec2(imgui.GetWindowWidth() - 30, sizeY))
end
function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
    
    local designText = function(text__)
        local pos = imgui.GetCursorPos()
        if sampGetChatDisplayMode() == 2 then
            for i = 1, 1 --[[Степень тени]] do
                imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
            end
        end
        imgui.SetCursorPos(pos)
    end
    
    local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

    local color = colors[col.Text]
    local start = 1
    local a, b = text:find('{........}', start)   
    
    while a do
        local t = text:sub(start, a - 1)
        if #t > 0 then
            designText(t)
            imgui.TextColored(color, t)
            imgui.SameLine(nil, 0)
        end

        local clr = text:sub(a + 1, b - 1)
        if clr:upper() == 'STANDART' then color = colors[col.Text]
        else
            clr = tonumber(clr, 16)
            if clr then
                local r = bit.band(bit.rshift(clr, 24), 0xFF)
                local g = bit.band(bit.rshift(clr, 16), 0xFF)
                local b = bit.band(bit.rshift(clr, 8), 0xFF)
                local a = bit.band(clr, 0xFF)
                color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
            end
        end

        start = b + 1
        a, b = text:find('{........}', start)
    end
    imgui.NewLine()
    if #text >= start then
        imgui.SameLine(nil, 0)
        designText(text:sub(start))
        imgui.TextColored(color, text:sub(start))
    end
end

function SoftBlueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
  
    style.WindowPadding = imgui.ImVec2(15, 15)
    style.WindowRounding = 10.0
    style.ChildRounding = 6.0
    style.FramePadding = imgui.ImVec2(7, 7) -- def imgui.ImVec2(8, 7)
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2(8, 8)
    style.ItemInnerSpacing = imgui.ImVec2(10, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 12.0
    style.GrabMinSize = 10.0
    style.GrabRounding = 6.0
    style.PopupRounding = 8
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.93, 1.00)
    style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.18, 0.20, 0.22, 0.30)
    style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.13, 0.13, 0.15, 1.00)
    style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
    style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
    style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
    style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.12, 1.00)
    style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
    style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
    style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
    style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
    style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
    style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.80, 0.80, 0.90, 1.00)
    style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
    style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
    style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
    style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
    style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
    style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.60, 0.60, 0.65, 1.00)
    style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
    style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
    style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
    style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
    style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
    style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.12, 0.80)
    style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.18, 0.20, 0.22, 1.00)
    style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
    style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
end