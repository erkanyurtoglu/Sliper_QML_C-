/****************************************************************************
** Meta object code from reading C++ file 'SensorManager.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/SensorManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'SensorManager.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSSensorManagerENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSSensorManagerENDCLASS = QtMocHelpers::stringData(
    "SensorManager",
    "basincChanged",
    "",
    "konumChanged",
    "hizChanged",
    "debiChanged",
    "egimXChanged",
    "egimYChanged",
    "hamAgirlikChanged",
    "hamMesafeChanged",
    "hamAccelDegisti",
    "veriGecerliChanged",
    "veriGuncellendi",
    "veriGuncelle",
    "basinc",
    "konum",
    "hiz",
    "debi",
    "egimX",
    "egimY",
    "hamAgirlikGuncelle",
    "hamAgirlik",
    "hamMesafeGuncelle",
    "hamMesafe",
    "hamAccelGuncelle",
    "x",
    "y",
    "z",
    "veriyiGecersizYap",
    "hamAccelX",
    "hamAccelY",
    "hamAccelZ",
    "veriGecerli"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSSensorManagerENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      16,   14, // methods
      12,  148, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      11,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  110,    2, 0x06,   13 /* Public */,
       3,    0,  111,    2, 0x06,   14 /* Public */,
       4,    0,  112,    2, 0x06,   15 /* Public */,
       5,    0,  113,    2, 0x06,   16 /* Public */,
       6,    0,  114,    2, 0x06,   17 /* Public */,
       7,    0,  115,    2, 0x06,   18 /* Public */,
       8,    0,  116,    2, 0x06,   19 /* Public */,
       9,    0,  117,    2, 0x06,   20 /* Public */,
      10,    0,  118,    2, 0x06,   21 /* Public */,
      11,    0,  119,    2, 0x06,   22 /* Public */,
      12,    0,  120,    2, 0x06,   23 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      13,    6,  121,    2, 0x02,   24 /* Public */,
      20,    1,  134,    2, 0x02,   31 /* Public */,
      22,    1,  137,    2, 0x02,   33 /* Public */,
      24,    3,  140,    2, 0x02,   35 /* Public */,
      28,    0,  147,    2, 0x02,   39 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double,   14,   15,   16,   17,   18,   19,
    QMetaType::Void, QMetaType::Double,   21,
    QMetaType::Void, QMetaType::Double,   23,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::Double,   25,   26,   27,
    QMetaType::Void,

 // properties: name, type, flags
      14, QMetaType::Double, 0x00015001, uint(0), 0,
      15, QMetaType::Double, 0x00015001, uint(1), 0,
      16, QMetaType::Double, 0x00015001, uint(2), 0,
      17, QMetaType::Double, 0x00015001, uint(3), 0,
      18, QMetaType::Double, 0x00015001, uint(4), 0,
      19, QMetaType::Double, 0x00015001, uint(5), 0,
      21, QMetaType::Double, 0x00015001, uint(6), 0,
      23, QMetaType::Double, 0x00015001, uint(7), 0,
      29, QMetaType::Double, 0x00015001, uint(8), 0,
      30, QMetaType::Double, 0x00015001, uint(8), 0,
      31, QMetaType::Double, 0x00015001, uint(8), 0,
      32, QMetaType::Bool, 0x00015001, uint(9), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject SensorManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSSensorManagerENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSSensorManagerENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSSensorManagerENDCLASS_t,
        // property 'basinc'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'konum'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hiz'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'debi'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'egimX'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'egimY'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hamAgirlik'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hamMesafe'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hamAccelX'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hamAccelY'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'hamAccelZ'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'veriGecerli'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<SensorManager, std::true_type>,
        // method 'basincChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'konumChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hizChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'debiChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'egimXChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'egimYChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hamAgirlikChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hamMesafeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'hamAccelDegisti'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'veriGecerliChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'veriGuncellendi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'veriGuncelle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'hamAgirlikGuncelle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'hamMesafeGuncelle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'hamAccelGuncelle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'veriyiGecersizYap'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void SensorManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SensorManager *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->basincChanged(); break;
        case 1: _t->konumChanged(); break;
        case 2: _t->hizChanged(); break;
        case 3: _t->debiChanged(); break;
        case 4: _t->egimXChanged(); break;
        case 5: _t->egimYChanged(); break;
        case 6: _t->hamAgirlikChanged(); break;
        case 7: _t->hamMesafeChanged(); break;
        case 8: _t->hamAccelDegisti(); break;
        case 9: _t->veriGecerliChanged(); break;
        case 10: _t->veriGuncellendi(); break;
        case 11: _t->veriGuncelle((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[6]))); break;
        case 12: _t->hamAgirlikGuncelle((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 13: _t->hamMesafeGuncelle((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 14: _t->hamAccelGuncelle((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3]))); break;
        case 15: _t->veriyiGecersizYap(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::basincChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::konumChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::hizChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::debiChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::egimXChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::egimYChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::hamAgirlikChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::hamMesafeChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::hamAccelDegisti; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::veriGecerliChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _t = void (SensorManager::*)();
            if (_t _q_method = &SensorManager::veriGuncellendi; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<SensorManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< double*>(_v) = _t->basinc(); break;
        case 1: *reinterpret_cast< double*>(_v) = _t->konum(); break;
        case 2: *reinterpret_cast< double*>(_v) = _t->hiz(); break;
        case 3: *reinterpret_cast< double*>(_v) = _t->debi(); break;
        case 4: *reinterpret_cast< double*>(_v) = _t->egimX(); break;
        case 5: *reinterpret_cast< double*>(_v) = _t->egimY(); break;
        case 6: *reinterpret_cast< double*>(_v) = _t->hamAgirlik(); break;
        case 7: *reinterpret_cast< double*>(_v) = _t->hamMesafe(); break;
        case 8: *reinterpret_cast< double*>(_v) = _t->hamAccelX(); break;
        case 9: *reinterpret_cast< double*>(_v) = _t->hamAccelY(); break;
        case 10: *reinterpret_cast< double*>(_v) = _t->hamAccelZ(); break;
        case 11: *reinterpret_cast< bool*>(_v) = _t->veriGecerli(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *SensorManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SensorManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSSensorManagerENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int SensorManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 16)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 16;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 16)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 16;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    }
    return _id;
}

// SIGNAL 0
void SensorManager::basincChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void SensorManager::konumChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void SensorManager::hizChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void SensorManager::debiChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void SensorManager::egimXChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void SensorManager::egimYChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void SensorManager::hamAgirlikChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void SensorManager::hamMesafeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void SensorManager::hamAccelDegisti()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void SensorManager::veriGecerliChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void SensorManager::veriGuncellendi()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}
QT_WARNING_POP
