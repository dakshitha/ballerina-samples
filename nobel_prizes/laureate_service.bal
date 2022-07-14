import ballerina/http;
import ballerina/regex;

type Affiliation record {
    string name;
    string city?;
    string country?;
};

type Prize record {
    string year;
    string category;
    string share;
    string motivation;
   (Affiliation|json[0])[] affiliations?;
    string overallMotivation?;
};

type Laureate record {
    string id;
    string firstname;
    string surname?;
    string born?;
    string died?;
    string bornCountry?;
    string bornCountryCode?;
    string bornCity?;
    string diedCountry?;
    string diedCountryCode?;
    string diedCity?;
    string gender?;
    Prize[] prizes;
};

type LaureateResults record {
    Laureate[] laureates;
};

Laureate[] laureates = check initializeLaureates();
int TEST_ID = 1010;

const API_URL = "https://api.nobelprize.org/v1";


function initializeLaureates() returns Laureate[]|error{
    http:Client nobelPrizes = check new(API_URL);
    LaureateResults laureateResults = check nobelPrizes->get("/laureate.json");
 
    return from Laureate laureate in laureateResults.laureates
    let boolean isAlive = laureate.died == "0000-00-00"
    select {id:laureate.id, firstname:laureate.firstname, 
            surname:laureate.surname?:"", bornCountry:laureate.bornCountry?:"", 
            gender:laureate.gender?:"", prizes:laureate.prizes, "isAlive":isAlive};
}


function getLaureateById(string id) returns Laureate|error{
    foreach Laureate laureate in laureates{
       if laureate.id == id {
           return laureate;
       }
   }
   return error("Laureate with id:" + id + " does not exist. \n");

}


service /nobelprize on new http:Listener(9090) {

   resource function get laureates(string? name, string? year,
       string? category, string? gender, string? country, string? isLiving) returns Laureate[]|error {   
 
       Laureate[] results = from Laureate laureate in laureates
       let string searchTerm = name?:"",
       string surname = laureate.surname?:"",
       string fullName = laureate.firstname + " " + surname,
       var isAlive = laureate["isAlive"]
 
       where (name == () || regex:matches(fullName,"(?i)^.*\\b" + searchTerm + "\\b.*$")) &&
       (year == () || laureate.prizes.filter(prize => prize.year == year).length() > 0) &&
       (category == () || laureate.prizes.filter(prize => prize.category == category).length() > 0) &&
       (gender == laureate.gender || gender == ()) &&
       (country == laureate.bornCountry || country == ()) &&
       (isLiving ==  isAlive.toString() || isLiving == ())
       select laureate;
 
       if results.length() == 0 {
           return error ("No match found.");
       }
      
       return results;
 
   }


    resource function get laureate/[string id]() returns Laureate|error {
       return getLaureateById(id);
    }

    resource function post laureate(@http:Payload Laureate newLaureate) returns Laureate|error {
        newLaureate.id = TEST_ID.toString();
        TEST_ID += 1;
       
        laureates.push(newLaureate);
        return getLaureateById(newLaureate.id);

    }
}