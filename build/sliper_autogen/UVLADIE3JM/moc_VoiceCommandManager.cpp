/****************************************************************************
** Meta object code from reading C++ file 'VoiceCommandManager.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/VoiceCommandManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'VoiceCommandManager.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSVoiceCommandManagerENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSVoiceCommandManagerENDCLASS = QtMocHelpers::stringData(
    "VoiceCommandManager",
    "etkinChanged",
    "",
    "dinliyorChanged",
    "modelHazirChanged",
    "sonKomutMetniChanged",
    "anlikMetinChanged",
    "sonHataChanged",
    "baslatKomutu",
    "durdurKomutu",
    "bitirKomutu",
    "devamKomutu",
    "ekleKomutu",
    "workerModelHazir",
    "hazir",
    "workerDinliyorDegisti",
    "dinliyor",
    "workerHataOlustu",
    "mesaj",
    "workerKomutAlgilandi",
    "komutTuru",
    "metin",
    "workerAnlikMetinDegisti",
    "etkin",
    "modelHazir",
    "sonKomutMetni",
    "anlikMetin",
    "sonHata"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSVoiceCommandManagerENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      16,   14, // methods
       6,  138, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      11,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  110,    2, 0x06,    7 /* Public */,
       3,    0,  111,    2, 0x06,    8 /* Public */,
       4,    0,  112,    2, 0x06,    9 /* Public */,
       5,    0,  113,    2, 0x06,   10 /* Public */,
       6,    0,  114,    2, 0x06,   11 /* Public */,
       7,    0,  115,    2, 0x06,   12 /* Public */,
       8,    0,  116,    2, 0x06,   13 /* Public */,
       9,    0,  117,    2, 0x06,   14 /* Public */,
      10,    0,  118,    2, 0x06,   15 /* Public */,
      11,    0,  119,    2, 0x06,   16 /* Public */,
      12,    0,  120,    2, 0x06,   17 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      13,    1,  121,    2, 0x08,   18 /* Private */,
      15,    1,  124,    2, 0x08,   20 /* Private */,
      17,    1,  127,    2, 0x08,   22 /* Private */,
      19,    2,  130,    2, 0x08,   24 /* Private */,
      22,    1,  135,    2, 0x08,   27 /* Private */,

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

 // slots: parameters
    QMetaType::Void, QMetaType::Bool,   14,
    QMetaType::Void, QMetaType::Bool,   16,
    QMetaType::Void, QMetaType::QString,   18,
    QMetaType::Void, QMetaType::Int, QMetaType::QString,   20,   21,
    QMetaType::Void, QMetaType::QString,   21,

 // properties: name, type, flags
      23, QMetaType::Bool, 0x00015103, uint(0), 0,
      16, QMetaType::Bool, 0x00015001, uint(1), 0,
      24, QMetaType::Bool, 0x00015001, uint(2), 0,
      25, QMetaType::QString, 0x00015001, uint(3), 0,
      26, QMetaType::QString, 0x00015001, uint(4), 0,
      27, QMetaType::QString, 0x00015001, uint(5), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject VoiceCommandManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSVoiceCommandManagerENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSVoiceCommandManagerENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSVoiceCommandManagerENDCLASS_t,
        // property 'etkin'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'dinliyor'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'modelHazir'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'sonKomutMetni'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'anlikMetin'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'sonHata'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<VoiceCommandManager, std::true_type>,
        // method 'etkinChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'dinliyorChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'modelHazirChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'sonKomutMetniChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'anlikMetinChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'sonHataChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'baslatKomutu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'durdurKomutu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'bitirKomutu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'devamKomutu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'ekleKomutu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'workerModelHazir'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'workerDinliyorDegisti'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'workerHataOlustu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'workerKomutAlgilandi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'workerAnlikMetinDegisti'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>
    >,
    nullptr
} };

void VoiceCommandManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<VoiceCommandManager *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->etkinChanged(); break;
        case 1: _t->dinliyorChanged(); break;
        case 2: _t->modelHazirChanged(); break;
        case 3: _t->sonKomutMetniChanged(); break;
        case 4: _t->anlikMetinChanged(); break;
        case 5: _t->sonHataChanged(); break;
        case 6: _t->baslatKomutu(); break;
        case 7: _t->durdurKomutu(); break;
        case 8: _t->bitirKomutu(); break;
        case 9: _t->devamKomutu(); break;
        case 10: _t->ekleKomutu(); break;
        case 11: _t->workerModelHazir((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 12: _t->workerDinliyorDegisti((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 13: _t->workerHataOlustu((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 14: _t->workerKomutAlgilandi((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 15: _t->workerAnlikMetinDegisti((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::etkinChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::dinliyorChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::modelHazirChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::sonKomutMetniChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::anlikMetinChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::sonHataChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::baslatKomutu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::durdurKomutu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::bitirKomutu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::devamKomutu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _t = void (VoiceCommandManager::*)();
            if (_t _q_method = &VoiceCommandManager::ekleKomutu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<VoiceCommandManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->etkin(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->dinliyor(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->modelHazir(); break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->sonKomutMetni(); break;
        case 4: *reinterpret_cast< QString*>(_v) = _t->anlikMetin(); break;
        case 5: *reinterpret_cast< QString*>(_v) = _t->sonHata(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<VoiceCommandManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setEtkin(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *VoiceCommandManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *VoiceCommandManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSVoiceCommandManagerENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int VoiceCommandManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void VoiceCommandManager::etkinChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void VoiceCommandManager::dinliyorChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void VoiceCommandManager::modelHazirChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void VoiceCommandManager::sonKomutMetniChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void VoiceCommandManager::anlikMetinChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void VoiceCommandManager::sonHataChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void VoiceCommandManager::baslatKomutu()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void VoiceCommandManager::durdurKomutu()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void VoiceCommandManager::bitirKomutu()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void VoiceCommandManager::devamKomutu()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void VoiceCommandManager::ekleKomutu()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}
QT_WARNING_POP
