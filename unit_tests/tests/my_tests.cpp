#include <json/json.h>
#include <iostream>
#include <string>

void test_dropped_null_placeholders() {
    std::cout << "Running test_dropped_null_placeholders..." << std::endl;
    std::string json = "[1,,3]";
    Json::Value root;
    
    Json::Reader reader;
    bool ok = reader.parse(json, root);
    std::cout << "Default reader (expected fail): " << ok << std::endl;
    
    // Test sa ukljucenom opcijom allowDroppedNullPlaceholders_
    Json::Features features;
    features.allowDroppedNullPlaceholders_ = true;
    Json::Reader reader2(features);
    ok = reader2.parse(json, root);
    
    if (ok) {
        std::cout << "Reader with allowDroppedNullPlaceholders (success): " << ok << std::endl;
        std::cout << "Parsed size: " << root.size() << " (Expected: 3)" << std::endl;
        std::cout << "Element at index 1 is null: " << root[1].isNull() << std::endl;
    }
}

int main() {
    test_dropped_null_placeholders();
    std::cout << "Targeted test finished!" << std::endl;
    return 0;
}
