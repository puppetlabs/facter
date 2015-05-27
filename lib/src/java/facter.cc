#include "com_puppetlabs_Facter.h"
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/export.h>
#include <boost/nowide/iostream.hpp>
#include <string>
#include <memory>

using namespace std;
using namespace facter::facts;
using namespace facter::logging;

static jclass object_class, long_class, double_class, boolean_class, hash_class;
static jmethodID long_constructor, double_constructor, boolean_constructor, hash_constructor, hash_put;
static std::unique_ptr<collection> facts_collection;

static string to_string(JNIEnv* env, jstring str)
{
    if (!str) {
        return {};
    }

    auto ptr = env->GetStringUTFChars(str, nullptr);
    if (!ptr) {
        return {};
    }

    auto size = env->GetStringUTFLength(str);
    string result(ptr, size);

    env->ReleaseStringUTFChars(str, ptr);
    return result;
}

static jclass find_class(JNIEnv* env, char const* name)
{
    // Find the class and return a global reference
    auto klass = env->FindClass(name);
    if (!klass) {
        return nullptr;
    }
    return static_cast<jclass>(env->NewGlobalRef(klass));
}

static jobject to_object(JNIEnv* env, value const* val)
{
    if (!val) {
        return nullptr;
    }
    if (auto ptr = dynamic_cast<string_value const*>(val)) {
        return env->NewStringUTF(ptr->value().c_str());
    }
    if (auto ptr = dynamic_cast<integer_value const*>(val)) {
        return env->NewObject(long_class, long_constructor, static_cast<jlong>(ptr->value()));
    }
    if (auto ptr = dynamic_cast<boolean_value const*>(val)) {
        return env->NewObject(boolean_class, boolean_constructor, static_cast<jboolean>(ptr->value()));
    }
    if (auto ptr = dynamic_cast<double_value const*>(val)) {
        return env->NewObject(double_class, double_constructor, static_cast<jdouble>(ptr->value()));
    }
    if (auto ptr = dynamic_cast<array_value const*>(val)) {
        auto array = env->NewObjectArray(ptr->size(), object_class, nullptr);

        // Recurse on each element of the array
        jsize index = 0;
        ptr->each([&](value const* element) {
            env->SetObjectArrayElement(array, index++, to_object(env, element));
            return true;
        });
        return array;
    }
    if (auto ptr = dynamic_cast<map_value const*>(val)) {
        auto hashmap = env->NewObject(hash_class, hash_constructor, static_cast<jint>(ptr->size()));

        // Recurse on each element in the map
        ptr->each([&](string const& name, value const* element) {
            env->CallObjectMethod(hashmap, hash_put, env->NewStringUTF(name.c_str()), to_object(env, element));
            return true;
        });
        return hashmap;
    }
    return nullptr;
}

extern "C" {
    LIBFACTER_EXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved)
    {
        JNIEnv* env;
        if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
            return JNI_ERR;
        }
        // For the classes, we need global refs
        object_class = find_class(env, "java/lang/Object");
        if (!object_class) {
            return JNI_ERR;
        }
        long_class = find_class(env, "java/lang/Long");
        if (!long_class) {
            return JNI_ERR;
        }
        double_class = find_class(env, "java/lang/Double");
        if (!double_class) {
            return JNI_ERR;
        }
        boolean_class = find_class(env, "java/lang/Boolean");
        if (!boolean_class) {
            return JNI_ERR;
        }
        hash_class = find_class(env, "java/util/HashMap");
        if (!hash_class) {
            return JNI_ERR;
        }

        // For the method ids, we can keep these cached as is
        long_constructor = env->GetMethodID(long_class, "<init>", "(J)V");
        double_constructor = env->GetMethodID(double_class, "<init>", "(D)V");
        boolean_constructor = env->GetMethodID(boolean_class, "<init>", "(Z)V");;
        hash_constructor = env->GetMethodID(hash_class, "<init>", "(I)V");
        hash_put = env->GetMethodID(hash_class, "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");

        setup_logging(boost::nowide::cerr);
        set_level(level::warning);

        facts_collection.reset(new collection());

        bool include_ruby_facts = true;
        facts_collection->add_default_facts(include_ruby_facts);
        facts_collection->add_external_facts();
        return JNI_VERSION_1_6;
    }

    LIBFACTER_EXPORT void JNI_OnUnload(JavaVM* vm, void* reserved)
    {
        // Delete the fact collection
        facts_collection.reset();

        JNIEnv* env;
        if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
            return;
        }
        // Free all of the global references above
        if (object_class) {
            env->DeleteGlobalRef(object_class);
            object_class = nullptr;
        }
        if (long_class) {
            env->DeleteGlobalRef(long_class);
            long_class = nullptr;
        }
        if (double_class) {
            env->DeleteGlobalRef(double_class);
            double_class = nullptr;
        }
        if (boolean_class) {
            env->DeleteGlobalRef(boolean_class);
            boolean_class = nullptr;
        }
        if (hash_class) {
            env->DeleteGlobalRef(hash_class);
            hash_class = nullptr;
        }
    }

    LIBFACTER_EXPORT jobject JNICALL Java_com_puppetlabs_Facter_lookup(JNIEnv* env, jclass klass, jstring name)
    {
        // Ensure initialized
        if (!facts_collection) {
            return nullptr;
        }

        return to_object(env, (*facts_collection)[to_string(env, name)]);
    }
}  // extern "C"
