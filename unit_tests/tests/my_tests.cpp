#include <json/json.h>
#include <iostream>
#include <string>
#include <cassert>
#include <utility>

void test_dropped_null_placeholders() {
    std::cout << "Running test_dropped_null_placeholders..." << std::endl;
    std::string json = "[1,,3]";
    Json::Value root;
    Json::Reader reader;
    
    bool ok = reader.parse(json, root);
    std::cout << "Default reader (expected fail): " << ok << std::endl;
    
    Json::Features features;
    features.allowDroppedNullPlaceholders_ = true;
    Json::Reader reader2(features);
    ok = reader2.parse(json, root);
    std::cout << "Reader with allowDroppedNullPlaceholders (expected success): " << ok << std::endl;
    if (ok) {
        std::cout << "Size: " << root.size() << std::endl;
        std::cout << "Element 1: " << root[1].asString() << " (is null: " << root[1].isNull() << ")" << std::endl;
    }
}

void test_move_semantics() {
    std::cout << "Running test_move_semantics..." << std::endl;
    Json::Value a("some big string to ensure it is not a small string optimization if any");
    Json::Value b(std::move(a));
    
    std::cout << "Moved-to value: " << b.asString() << std::endl;
    
    Json::Value c;
    c = std::move(b);
    std::cout << "Moved-to value again: " << c.asString() << std::endl;

    Json::Value obj;
    std::string key = "very_long_key_name_to_avoid_small_string";
    obj[std::move(key)] = 123;
    std::cout << "Object key value: " << obj["very_long_key_name_to_avoid_small_string"].asInt() << std::endl;
}

void test_value_misc() {
    std::cout << "Running test_value_misc..." << std::endl;
    Json::Value v(123.456);
    std::cout << "Value as bool: " << v.asBool() << std::endl;
    
    Json::Value array(Json::arrayValue);
    array.append(1);
    array.append(2);
    
    Json::Value v1(10), v2(20);
    std::cout << "v1 < v2: " << (v1 < v2) << std::endl;
    std::cout << "v1 == v2: " << (v1 == v2) << std::endl;
}

int main() {
    test_dropped_null_placeholders();
    test_move_semantics();
    test_value_misc();
    std::cout << "All targeted tests finished!" << std::endl;
    return 0;
}
