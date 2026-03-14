.pragma library

var rules = {
    en: function(n) { return n === 1 ? "one" : "other" },
    pl: function(n) {
        if (n === 1) return "one"
        const t = n % 10, h = n % 100
        if (t >= 2 && t <= 4 && (h < 12 || h > 14)) return "few"
        return "many"
    }
}

var strings = {
    "Tasks":     { pl: "Zadania" },
    "Add task":  { pl: "Dodaj zadanie" },
    "Refresh":   { pl: "Odśwież" },
    "Add":       { pl: "Dodaj" },
    "Mark done": { pl: "Oznacz jako wykonane" },
    "yesterday": { pl: "wczoraj" },
    "now":       { pl: "teraz" },
    "tomorrow":  { pl: "jutro" },
    "e.g. Buy milk +shopping priority:H":
                 { pl: "np. Kup mleko +zakupy priority:H" },

    '%{count} pending': {
        en: { one: "%{count} pending", other: "%{count} pending" },
        pl: { one: "%{count} oczekujące", few: "%{count} oczekujące", many: "%{count} oczekujących" }
    }
}

function tr(key, lang) {
    const s = strings[key]
    if (!s) return key

    const loc = s[lang]
    if (typeof loc === "string") return loc

    return key
}

function trn(key, count, lang) {
    const s = strings[key]
    if (!s) return key.replace("%{count}", count)

    const forms = s[lang] || s["en"]
    const rule = rules[lang] || rules["en"]
    const form = forms[rule(count)] || forms["other"] || forms["many"]
    return form.replace("%{count}", count)
}
