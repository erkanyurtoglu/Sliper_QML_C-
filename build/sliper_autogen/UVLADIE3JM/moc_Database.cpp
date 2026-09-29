/****************************************************************************
** Meta object code from reading C++ file 'Database.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/Database.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Database.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.7.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSDatabaseENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSDatabaseENDCLASS = QtMocHelpers::stringData(
    "Database",
    "olcumBaslat",
    "",
    "musteri",
    "recete",
    "agirlik",
    "yer",
    "yorum",
    "olcumBilgisiGuncelle",
    "olcumId",
    "olcumSil",
    "tumOlcumleriGetir",
    "olcumBilgisiGetir",
    "strokeKaydet",
    "stroke",
    "strokeVerileriGetir",
    "strokeHamVeriGetir",
    "strokeId",
    "strokeSeciliAyarla",
    "secili",
    "strokeSil",
    "binghamHesapla",
    "tahminAyarlariGetir",
    "tahminAyarlariKaydet",
    "ayarlar",
    "varsayilanTahminAyarlariGetir",
    "tahminTablosuGetir",
    "ayarGetir",
    "anahtar",
    "varsayilan",
    "ayarKaydet",
    "deger",
    "csvDisaAktar",
    "xmlDisaAktar",
    "veriTabaniDisaAktar",
    "veriTabaniIcaAktar",
    "kaynakDosyaYolu",
    "tumVeriyiSil",
    "kalibrasyonKaydet",
    "sensor",
    "deger1",
    "deger2",
    "kalibrasyonGetir",
    "loadCellNoktalariKaydet",
    "noktalar",
    "loadCellNoktalariGetir",
    "mesafeNoktalariKaydet",
    "mesafeNoktalariGetir",
    "egimKalibrasyonuKaydet",
    "biasX",
    "biasY",
    "biasZ",
    "gainX",
    "gainY",
    "gainZ",
    "egimKalibrasyonuGetir",
    "kalibrasyonTarihiKaydet",
    "kalibrasyonTarihiGetir"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSDatabaseENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      35,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       1,    5,  224,    2, 0x02,    1 /* Public */,
       1,    4,  235,    2, 0x22,    7 /* Public | MethodCloned */,
       1,    3,  244,    2, 0x22,   12 /* Public | MethodCloned */,
       8,    5,  251,    2, 0x02,   16 /* Public */,
      10,    1,  262,    2, 0x02,   22 /* Public */,
      11,    0,  265,    2, 0x02,   24 /* Public */,
      12,    1,  266,    2, 0x02,   25 /* Public */,
      13,    3,  269,    2, 0x02,   27 /* Public */,
      15,    1,  276,    2, 0x02,   31 /* Public */,
      16,    1,  279,    2, 0x02,   33 /* Public */,
      18,    2,  282,    2, 0x02,   35 /* Public */,
      20,    1,  287,    2, 0x02,   38 /* Public */,
      21,    1,  290,    2, 0x02,   40 /* Public */,
      22,    1,  293,    2, 0x02,   42 /* Public */,
      23,    2,  296,    2, 0x02,   44 /* Public */,
      25,    0,  301,    2, 0x02,   47 /* Public */,
      26,    1,  302,    2, 0x02,   48 /* Public */,
      27,    2,  305,    2, 0x02,   50 /* Public */,
      27,    1,  310,    2, 0x22,   53 /* Public | MethodCloned */,
      30,    2,  313,    2, 0x02,   55 /* Public */,
      32,    1,  318,    2, 0x02,   58 /* Public */,
      33,    1,  321,    2, 0x02,   60 /* Public */,
      34,    0,  324,    2, 0x02,   62 /* Public */,
      35,    1,  325,    2, 0x02,   63 /* Public */,
      37,    0,  328,    2, 0x02,   65 /* Public */,
      38,    3,  329,    2, 0x02,   66 /* Public */,
      42,    1,  336,    2, 0x02,   70 /* Public */,
      43,    1,  339,    2, 0x02,   72 /* Public */,
      45,    0,  342,    2, 0x02,   74 /* Public */,
      46,    1,  343,    2, 0x02,   75 /* Public */,
      47,    0,  346,    2, 0x02,   77 /* Public */,
      48,    6,  347,    2, 0x02,   78 /* Public */,
      55,    0,  360,    2, 0x02,   85 /* Public */,
      56,    1,  361,    2, 0x02,   86 /* Public */,
      57,    1,  364,    2, 0x02,   88 /* Public */,

 // methods: parameters
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double, QMetaType::QString, QMetaType::QString,    3,    4,    5,    6,    7,
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double, QMetaType::QString,    3,    4,    5,    6,
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double,    3,    4,    5,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    9,    6,    3,    4,    7,
    QMetaType::Bool, QMetaType::Int,    9,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::Int, QMetaType::Int, QMetaType::QVariantMap, QMetaType::Double,    9,   14,    5,
    QMetaType::QVariantList, QMetaType::Int,    9,
    QMetaType::QVariantMap, QMetaType::Int,   17,
    QMetaType::Bool, QMetaType::Int, QMetaType::Bool,   17,   19,
    QMetaType::Bool, QMetaType::Int,   17,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantMap,    9,   24,
    QMetaType::QVariantMap,
    QMetaType::QVariantList, QMetaType::Int,    9,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,   28,   29,
    QMetaType::QString, QMetaType::QString,   28,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   28,   31,
    QMetaType::QString, QMetaType::Int,    9,
    QMetaType::QString, QMetaType::Int,    9,
    QMetaType::QString,
    QMetaType::Bool, QMetaType::QString,   36,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::Double, QMetaType::Double,   39,   40,   41,
    QMetaType::QVariantMap, QMetaType::QString,   39,
    QMetaType::Bool, QMetaType::QVariantList,   44,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QVariantList,   44,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double,   49,   50,   51,   52,   53,   54,
    QMetaType::QVariantMap,
    QMetaType::Void, QMetaType::QString,   39,
    QMetaType::QString, QMetaType::QString,   39,

       0        // eod
};

Q_CONSTINIT const QMetaObject Database::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSDatabaseENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSDatabaseENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSDatabaseENDCLASS_t,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<Database, std::true_type>,
        // method 'olcumBaslat'
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'olcumBaslat'
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'olcumBaslat'
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'olcumBilgisiGuncelle'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'olcumSil'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'tumOlcumleriGetir'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'olcumBilgisiGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'strokeKaydet'
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantMap &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'strokeVerileriGetir'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'strokeHamVeriGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'strokeSeciliAyarla'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'strokeSil'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'binghamHesapla'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'tahminAyarlariGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'tahminAyarlariKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantMap &, std::false_type>,
        // method 'varsayilanTahminAyarlariGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        // method 'tahminTablosuGetir'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'ayarGetir'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'ayarGetir'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'ayarKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'csvDisaAktar'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'xmlDisaAktar'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'veriTabaniDisaAktar'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        // method 'veriTabaniIcaAktar'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'tumVeriyiSil'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'kalibrasyonKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'kalibrasyonGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'loadCellNoktalariKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'loadCellNoktalariGetir'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'mesafeNoktalariKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'mesafeNoktalariGetir'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'egimKalibrasyonuKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'egimKalibrasyonuGetir'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        // method 'kalibrasyonTarihiKaydet'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'kalibrasyonTarihiGetir'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>
    >,
    nullptr
} };

void Database::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Database *>(_o);
        (void)_t;
        switch (_id) {
        case 0: { int _r = _t->olcumBaslat((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 1: { int _r = _t->olcumBaslat((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 2: { int _r = _t->olcumBaslat((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 3: { bool _r = _t->olcumBilgisiGuncelle((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 4: { bool _r = _t->olcumSil((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 5: { QVariantList _r = _t->tumOlcumleriGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 6: { QVariantMap _r = _t->olcumBilgisiGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 7: { int _r = _t->strokeKaydet((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 8: { QVariantList _r = _t->strokeVerileriGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 9: { QVariantMap _r = _t->strokeHamVeriGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 10: { bool _r = _t->strokeSeciliAyarla((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 11: { bool _r = _t->strokeSil((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 12: { QVariantMap _r = _t->binghamHesapla((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 13: { QVariantMap _r = _t->tahminAyarlariGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 14: { bool _r = _t->tahminAyarlariKaydet((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 15: { QVariantMap _r = _t->varsayilanTahminAyarlariGetir();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->tahminTablosuGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QString _r = _t->ayarGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 18: { QString _r = _t->ayarGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 19: { bool _r = _t->ayarKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 20: { QString _r = _t->csvDisaAktar((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 21: { QString _r = _t->xmlDisaAktar((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 22: { QString _r = _t->veriTabaniDisaAktar();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 23: { bool _r = _t->veriTabaniIcaAktar((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 24: { bool _r = _t->tumVeriyiSil();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 25: { bool _r = _t->kalibrasyonKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 26: { QVariantMap _r = _t->kalibrasyonGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 27: { bool _r = _t->loadCellNoktalariKaydet((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 28: { QVariantList _r = _t->loadCellNoktalariGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 29: { bool _r = _t->mesafeNoktalariKaydet((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 30: { QVariantList _r = _t->mesafeNoktalariGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 31: { bool _r = _t->egimKalibrasyonuKaydet((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 32: { QVariantMap _r = _t->egimKalibrasyonuGetir();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 33: _t->kalibrasyonTarihiKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 34: { QString _r = _t->kalibrasyonTarihiGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject *Database::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Database::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSDatabaseENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Database::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 35)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 35;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 35)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 35;
    }
    return _id;
}
QT_WARNING_POP
