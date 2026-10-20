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
    "olcumDarasiKaydet",
    "daraBasinciMbar",
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
      36,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       1,    5,  230,    2, 0x02,    1 /* Public */,
       1,    4,  241,    2, 0x22,    7 /* Public | MethodCloned */,
       1,    3,  250,    2, 0x22,   12 /* Public | MethodCloned */,
       8,    5,  257,    2, 0x02,   16 /* Public */,
      10,    1,  268,    2, 0x02,   22 /* Public */,
      11,    2,  271,    2, 0x02,   24 /* Public */,
      13,    0,  276,    2, 0x02,   27 /* Public */,
      14,    1,  277,    2, 0x02,   28 /* Public */,
      15,    3,  280,    2, 0x02,   30 /* Public */,
      17,    1,  287,    2, 0x02,   34 /* Public */,
      18,    1,  290,    2, 0x02,   36 /* Public */,
      20,    2,  293,    2, 0x02,   38 /* Public */,
      22,    1,  298,    2, 0x02,   41 /* Public */,
      23,    1,  301,    2, 0x02,   43 /* Public */,
      24,    1,  304,    2, 0x02,   45 /* Public */,
      25,    2,  307,    2, 0x02,   47 /* Public */,
      27,    0,  312,    2, 0x02,   50 /* Public */,
      28,    1,  313,    2, 0x02,   51 /* Public */,
      29,    2,  316,    2, 0x02,   53 /* Public */,
      29,    1,  321,    2, 0x22,   56 /* Public | MethodCloned */,
      32,    2,  324,    2, 0x02,   58 /* Public */,
      34,    1,  329,    2, 0x02,   61 /* Public */,
      35,    1,  332,    2, 0x02,   63 /* Public */,
      36,    0,  335,    2, 0x02,   65 /* Public */,
      37,    1,  336,    2, 0x02,   66 /* Public */,
      39,    0,  339,    2, 0x02,   68 /* Public */,
      40,    3,  340,    2, 0x02,   69 /* Public */,
      44,    1,  347,    2, 0x02,   73 /* Public */,
      45,    1,  350,    2, 0x02,   75 /* Public */,
      47,    0,  353,    2, 0x02,   77 /* Public */,
      48,    1,  354,    2, 0x02,   78 /* Public */,
      49,    0,  357,    2, 0x02,   80 /* Public */,
      50,    6,  358,    2, 0x02,   81 /* Public */,
      57,    0,  371,    2, 0x02,   88 /* Public */,
      58,    1,  372,    2, 0x02,   89 /* Public */,
      59,    1,  375,    2, 0x02,   91 /* Public */,

 // methods: parameters
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double, QMetaType::QString, QMetaType::QString,    3,    4,    5,    6,    7,
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double, QMetaType::QString,    3,    4,    5,    6,
    QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double,    3,    4,    5,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    9,    6,    3,    4,    7,
    QMetaType::Bool, QMetaType::Int,    9,
    QMetaType::Bool, QMetaType::Int, QMetaType::Double,    9,   12,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::Int, QMetaType::Int, QMetaType::QVariantMap, QMetaType::Double,    9,   16,    5,
    QMetaType::QVariantList, QMetaType::Int,    9,
    QMetaType::QVariantMap, QMetaType::Int,   19,
    QMetaType::Bool, QMetaType::Int, QMetaType::Bool,   19,   21,
    QMetaType::Bool, QMetaType::Int,   19,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::QVariantMap, QMetaType::Int,    9,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantMap,    9,   26,
    QMetaType::QVariantMap,
    QMetaType::QVariantList, QMetaType::Int,    9,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,   30,   31,
    QMetaType::QString, QMetaType::QString,   30,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   30,   33,
    QMetaType::QString, QMetaType::Int,    9,
    QMetaType::QString, QMetaType::Int,    9,
    QMetaType::QString,
    QMetaType::Bool, QMetaType::QString,   38,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::Double, QMetaType::Double,   41,   42,   43,
    QMetaType::QVariantMap, QMetaType::QString,   41,
    QMetaType::Bool, QMetaType::QVariantList,   46,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QVariantList,   46,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double,   51,   52,   53,   54,   55,   56,
    QMetaType::QVariantMap,
    QMetaType::Void, QMetaType::QString,   41,
    QMetaType::QString, QMetaType::QString,   41,

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
        // method 'olcumDarasiKaydet'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
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
        case 5: { bool _r = _t->olcumDarasiKaydet((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 6: { QVariantList _r = _t->tumOlcumleriGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 7: { QVariantMap _r = _t->olcumBilgisiGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 8: { int _r = _t->strokeKaydet((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 9: { QVariantList _r = _t->strokeVerileriGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 10: { QVariantMap _r = _t->strokeHamVeriGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 11: { bool _r = _t->strokeSeciliAyarla((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 12: { bool _r = _t->strokeSil((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 13: { QVariantMap _r = _t->binghamHesapla((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 14: { QVariantMap _r = _t->tahminAyarlariGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 15: { bool _r = _t->tahminAyarlariKaydet((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantMap _r = _t->varsayilanTahminAyarlariGetir();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->tahminTablosuGetir((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QString _r = _t->ayarGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 19: { QString _r = _t->ayarGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 20: { bool _r = _t->ayarKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 21: { QString _r = _t->csvDisaAktar((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 22: { QString _r = _t->xmlDisaAktar((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 23: { QString _r = _t->veriTabaniDisaAktar();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 24: { bool _r = _t->veriTabaniIcaAktar((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 25: { bool _r = _t->tumVeriyiSil();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 26: { bool _r = _t->kalibrasyonKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantMap _r = _t->kalibrasyonGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 28: { bool _r = _t->loadCellNoktalariKaydet((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 29: { QVariantList _r = _t->loadCellNoktalariGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 30: { bool _r = _t->mesafeNoktalariKaydet((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 31: { QVariantList _r = _t->mesafeNoktalariGetir();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 32: { bool _r = _t->egimKalibrasyonuKaydet((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 33: { QVariantMap _r = _t->egimKalibrasyonuGetir();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 34: _t->kalibrasyonTarihiKaydet((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 35: { QString _r = _t->kalibrasyonTarihiGetir((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
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
        if (_id < 36)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 36;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 36)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 36;
    }
    return _id;
}
QT_WARNING_POP
