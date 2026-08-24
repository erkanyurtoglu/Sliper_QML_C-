/****************************************************************************
** Meta object code from reading C++ file 'VoiceRecognitionWorker.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.7.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/VoiceRecognitionWorker.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'VoiceRecognitionWorker.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSVoiceRecognitionWorkerENDCLASS_t {};
constexpr auto qt_meta_stringdata_CLASSVoiceRecognitionWorkerENDCLASS = QtMocHelpers::stringData(
    "VoiceRecognitionWorker",
    "modelHazir",
    "",
    "basarili",
    "dinliyorDegisti",
    "dinliyor",
    "hataOlustu",
    "mesaj",
    "komutAlgilandi",
    "komutTuru",
    "metin",
    "anlikMetinDegisti",
    "modeliYukle",
    "dinlemeyeBasla",
    "dinlemeyiDurdur",
    "sesVerisiHazir",
    "KomutTuru",
    "KomutBaslat",
    "KomutDurdur",
    "KomutBitir",
    "KomutDevam"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSVoiceRecognitionWorkerENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       1,   89, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    1,   68,    2, 0x06,    2 /* Public */,
       4,    1,   71,    2, 0x06,    4 /* Public */,
       6,    1,   74,    2, 0x06,    6 /* Public */,
       8,    2,   77,    2, 0x06,    8 /* Public */,
      11,    1,   82,    2, 0x06,   11 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      12,    0,   85,    2, 0x0a,   13 /* Public */,
      13,    0,   86,    2, 0x0a,   14 /* Public */,
      14,    0,   87,    2, 0x0a,   15 /* Public */,
      15,    0,   88,    2, 0x08,   16 /* Private */,

 // signals: parameters
    QMetaType::Void, QMetaType::Bool,    3,
    QMetaType::Void, QMetaType::Bool,    5,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void, QMetaType::Int, QMetaType::QString,    9,   10,
    QMetaType::Void, QMetaType::QString,   10,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // enums: name, alias, flags, count, data
      16,   16, 0x0,    4,   94,

 // enum data: key, value
      17, uint(VoiceRecognitionWorker::KomutBaslat),
      18, uint(VoiceRecognitionWorker::KomutDurdur),
      19, uint(VoiceRecognitionWorker::KomutBitir),
      20, uint(VoiceRecognitionWorker::KomutDevam),

       0        // eod
};

Q_CONSTINIT const QMetaObject VoiceRecognitionWorker::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSVoiceRecognitionWorkerENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSVoiceRecognitionWorkerENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSVoiceRecognitionWorkerENDCLASS_t,
        // enum 'KomutTuru'
        QtPrivate::TypeAndForceComplete<VoiceRecognitionWorker::KomutTuru, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<VoiceRecognitionWorker, std::true_type>,
        // method 'modelHazir'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'dinliyorDegisti'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'hataOlustu'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'komutAlgilandi'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'anlikMetinDegisti'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'modeliYukle'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'dinlemeyeBasla'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'dinlemeyiDurdur'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'sesVerisiHazir'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void VoiceRecognitionWorker::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<VoiceRecognitionWorker *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->modelHazir((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 1: _t->dinliyorDegisti((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 2: _t->hataOlustu((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 3: _t->komutAlgilandi((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 4: _t->anlikMetinDegisti((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 5: _t->modeliYukle(); break;
        case 6: _t->dinlemeyeBasla(); break;
        case 7: _t->dinlemeyiDurdur(); break;
        case 8: _t->sesVerisiHazir(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (VoiceRecognitionWorker::*)(bool );
            if (_t _q_method = &VoiceRecognitionWorker::modelHazir; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (VoiceRecognitionWorker::*)(bool );
            if (_t _q_method = &VoiceRecognitionWorker::dinliyorDegisti; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (VoiceRecognitionWorker::*)(const QString & );
            if (_t _q_method = &VoiceRecognitionWorker::hataOlustu; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (VoiceRecognitionWorker::*)(int , const QString & );
            if (_t _q_method = &VoiceRecognitionWorker::komutAlgilandi; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (VoiceRecognitionWorker::*)(const QString & );
            if (_t _q_method = &VoiceRecognitionWorker::anlikMetinDegisti; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
    }
}

const QMetaObject *VoiceRecognitionWorker::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *VoiceRecognitionWorker::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSVoiceRecognitionWorkerENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int VoiceRecognitionWorker::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
    }
    return _id;
}

// SIGNAL 0
void VoiceRecognitionWorker::modelHazir(bool _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void VoiceRecognitionWorker::dinliyorDegisti(bool _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void VoiceRecognitionWorker::hataOlustu(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void VoiceRecognitionWorker::komutAlgilandi(int _t1, const QString & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void VoiceRecognitionWorker::anlikMetinDegisti(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}
QT_WARNING_POP
