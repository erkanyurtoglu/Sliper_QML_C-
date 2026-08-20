/****************************************************************************
** Meta object code from reading C++ file 'Calculator.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/Calculator.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'Calculator.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSCalculatorENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSCalculatorENDCLASS = QtMocHelpers::stringData(
    "Calculator",
    "durumChanged",
    "",
    "strokeSayisiChanged",
    "duraklatildiChanged",
    "esiklerChanged",
    "konumGuncelle",
    "konum",
    "duraklat",
    "devamEt",
    "sifirla",
    "esikleriAyarla",
    "ust",
    "alt",
    "durum",
    "strokeSayisi",
    "duraklatildi",
    "ustEsik",
    "altEsik"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSCalculatorENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       5,   83, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       4,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   68,    2, 0x06,    6 /* Public */,
       3,    0,   69,    2, 0x06,    7 /* Public */,
       4,    0,   70,    2, 0x06,    8 /* Public */,
       5,    0,   71,    2, 0x06,    9 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       6,    1,   72,    2, 0x02,   10 /* Public */,
       8,    0,   75,    2, 0x02,   12 /* Public */,
       9,    0,   76,    2, 0x02,   13 /* Public */,
      10,    0,   77,    2, 0x02,   14 /* Public */,
      11,    2,   78,    2, 0x02,   15 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void, QMetaType::Double,    7,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Double, QMetaType::Double,   12,   13,

 // properties: name, type, flags
      14, QMetaType::QString, 0x00015001, uint(0), 0,
      15, QMetaType::Int, 0x00015001, uint(1), 0,
      16, QMetaType::Bool, 0x00015001, uint(2), 0,
      17, QMetaType::Double, 0x00015001, uint(3), 0,
      18, QMetaType::Double, 0x00015001, uint(3), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject Calculator::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSCalculatorENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSCalculatorENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSCalculatorENDCLASS_t,
        // property 'durum'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'strokeSayisi'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'duraklatildi'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'ustEsik'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'altEsik'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<Calculator, std::true_type>,
        // method 'durumChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'strokeSayisiChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'duraklatildiChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'esiklerChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'konumGuncelle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'duraklat'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'devamEt'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'sifirla'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'esikleriAyarla'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>
    >,
    nullptr
} };

void Calculator::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Calculator *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->durumChanged(); break;
        case 1: _t->strokeSayisiChanged(); break;
        case 2: _t->duraklatildiChanged(); break;
        case 3: _t->esiklerChanged(); break;
        case 4: _t->konumGuncelle((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 5: _t->duraklat(); break;
        case 6: _t->devamEt(); break;
        case 7: _t->sifirla(); break;
        case 8: _t->esikleriAyarla((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Calculator::*)();
            if (_t _q_method = &Calculator::durumChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (Calculator::*)();
            if (_t _q_method = &Calculator::strokeSayisiChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (Calculator::*)();
            if (_t _q_method = &Calculator::duraklatildiChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (Calculator::*)();
            if (_t _q_method = &Calculator::esiklerChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<Calculator *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->durum(); break;
        case 1: *reinterpret_cast< int*>(_v) = _t->strokeSayisi(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->duraklatildi(); break;
        case 3: *reinterpret_cast< double*>(_v) = _t->ustEsik(); break;
        case 4: *reinterpret_cast< double*>(_v) = _t->altEsik(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *Calculator::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Calculator::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSCalculatorENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Calculator::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 9;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void Calculator::durumChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void Calculator::strokeSayisiChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void Calculator::duraklatildiChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void Calculator::esiklerChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}
QT_WARNING_POP
