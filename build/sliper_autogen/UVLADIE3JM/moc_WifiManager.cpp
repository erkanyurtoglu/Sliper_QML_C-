/****************************************************************************
** Meta object code from reading C++ file 'WifiManager.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/WifiManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'WifiManager.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSWifiManagerENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSWifiManagerENDCLASS = QtMocHelpers::stringData(
    "WifiManager",
    "baglandiChanged",
    "",
    "baglaniyorChanged",
    "durumMesajiChanged",
    "daraBasinciMbarChanged",
    "hareketsizlikNedeniyleBaglantiKesildi",
    "soketBaglandi",
    "soketAyrildi",
    "soketHata",
    "QAbstractSocket::SocketError",
    "hata",
    "veriHazir",
    "hareketsizlikKontrolEt",
    "veriAkisiniKontrolEt",
    "baglantiZamanAsimiOldu",
    "baglan",
    "baglantiyiKes",
    "kalibrasyonYenidenYukle",
    "daraAl",
    "daraSifirla",
    "baglandi",
    "baglaniyor",
    "durumMesaji",
    "daraBasinciMbar",
    "daraUstSiniriMbar"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSWifiManagerENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      17,   14, // methods
       5,  135, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  116,    2, 0x06,    6 /* Public */,
       3,    0,  117,    2, 0x06,    7 /* Public */,
       4,    0,  118,    2, 0x06,    8 /* Public */,
       5,    0,  119,    2, 0x06,    9 /* Public */,
       6,    0,  120,    2, 0x06,   10 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
       7,    0,  121,    2, 0x08,   11 /* Private */,
       8,    0,  122,    2, 0x08,   12 /* Private */,
       9,    1,  123,    2, 0x08,   13 /* Private */,
      12,    0,  126,    2, 0x08,   15 /* Private */,
      13,    0,  127,    2, 0x08,   16 /* Private */,
      14,    0,  128,    2, 0x08,   17 /* Private */,
      15,    0,  129,    2, 0x08,   18 /* Private */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      16,    0,  130,    2, 0x02,   19 /* Public */,
      17,    0,  131,    2, 0x02,   20 /* Public */,
      18,    0,  132,    2, 0x02,   21 /* Public */,
      19,    0,  133,    2, 0x02,   22 /* Public */,
      20,    0,  134,    2, 0x02,   23 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 10,   11,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Bool,
    QMetaType::Void,

 // properties: name, type, flags
      21, QMetaType::Bool, 0x00015001, uint(0), 0,
      22, QMetaType::Bool, 0x00015001, uint(1), 0,
      23, QMetaType::QString, 0x00015001, uint(2), 0,
      24, QMetaType::Double, 0x00015001, uint(3), 0,
      25, QMetaType::Double, 0x00015401, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject WifiManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSWifiManagerENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSWifiManagerENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSWifiManagerENDCLASS_t,
        // property 'baglandi'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'baglaniyor'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'durumMesaji'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'daraBasinciMbar'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'daraUstSiniriMbar'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<WifiManager, std::true_type>,
        // method 'baglandiChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'baglaniyorChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'durumMesajiChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'daraBasinciMbarChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hareketsizlikNedeniyleBaglantiKesildi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'soketBaglandi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'soketAyrildi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'soketHata'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<QAbstractSocket::SocketError, std::false_type>,
        // method 'veriHazir'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hareketsizlikKontrolEt'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'veriAkisiniKontrolEt'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'baglantiZamanAsimiOldu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'baglan'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'baglantiyiKes'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'kalibrasyonYenidenYukle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'daraAl'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'daraSifirla'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void WifiManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<WifiManager *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->baglandiChanged(); break;
        case 1: _t->baglaniyorChanged(); break;
        case 2: _t->durumMesajiChanged(); break;
        case 3: _t->daraBasinciMbarChanged(); break;
        case 4: _t->hareketsizlikNedeniyleBaglantiKesildi(); break;
        case 5: _t->soketBaglandi(); break;
        case 6: _t->soketAyrildi(); break;
        case 7: _t->soketHata((*reinterpret_cast< std::add_pointer_t<QAbstractSocket::SocketError>>(_a[1]))); break;
        case 8: _t->veriHazir(); break;
        case 9: _t->hareketsizlikKontrolEt(); break;
        case 10: _t->veriAkisiniKontrolEt(); break;
        case 11: _t->baglantiZamanAsimiOldu(); break;
        case 12: _t->baglan(); break;
        case 13: _t->baglantiyiKes(); break;
        case 14: _t->kalibrasyonYenidenYukle(); break;
        case 15: { bool _r = _t->daraAl();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 16: _t->daraSifirla(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 7:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QAbstractSocket::SocketError >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (WifiManager::*)();
            if (_t _q_method = &WifiManager::baglandiChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (_t _q_method = &WifiManager::baglaniyorChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (_t _q_method = &WifiManager::durumMesajiChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (_t _q_method = &WifiManager::daraBasinciMbarChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (_t _q_method = &WifiManager::hareketsizlikNedeniyleBaglantiKesildi; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<WifiManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->baglandi(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->baglaniyor(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->durumMesaji(); break;
        case 3: *reinterpret_cast< double*>(_v) = _t->daraBasinciMbar(); break;
        case 4: *reinterpret_cast< double*>(_v) = _t->daraUstSiniriMbar(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *WifiManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WifiManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSWifiManagerENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WifiManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 17)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 17;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 17)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 17;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void WifiManager::baglandiChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void WifiManager::baglaniyorChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void WifiManager::durumMesajiChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void WifiManager::daraBasinciMbarChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void WifiManager::hareketsizlikNedeniyleBaglantiKesildi()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}
QT_WARNING_POP
