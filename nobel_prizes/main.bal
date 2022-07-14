 
// Reading JSON data from the nobelprize API

import ballerina/io;
import ballerina/http;
 
const API_URL = "https://api.nobelprize.org/v1";
 
public function main() returns error? {
  http:Client nobelPrizes = check new(API_URL);
  json payload = check nobelPrizes->get("/laureate.json");
  json[] laureates = check payload.laureates.ensureType();
  foreach var laureate in laureates {
      io:println(laureate.id, ":", laureate.firstname, " ", laureate.surname);
 }
}