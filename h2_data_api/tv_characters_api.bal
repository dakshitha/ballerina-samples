import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/io;
import ballerina/http;

// Defines a record to load the query result schema 
type TVCharacter record {
    int id;
    string firstName;
    string lastName;
    string tvShow;
    int voteCount;
};

// Initializes the JDBC client.
final jdbc:Client jdbcClient;

function init() returns error? {
    jdbcClient = check new ("jdbc:h2:file:./target/tv_characters",
        "rootUser", "rootPassword");
    io:println("Service initialized.. ");    
}

service /tv_characters on new http:Listener(9090) {

    isolated resource function get top10() returns TVCharacter[]|error {
        TVCharacter[] characters = [];
        stream<TVCharacter, error?> resultStream =
            jdbcClient->query(`SELECT * FROM TV_Characters ORDER BY voteCount DESC LIMIT 10;`);

        check from TVCharacter character in resultStream
            do {
                characters.push(character);
            };
        check resultStream.close();
        return characters;

    }

    isolated resource function post character(@http:Payload TVCharacter character) returns int|error? {

        sql:ExecutionResult result = check jdbcClient->execute(`INSERT INTO TV_Characters (firstName,
            lastName, tvShow, voteCount) VALUES (${character.firstName},${character.lastName},${character.tvShow}, 1)`);

        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return lastInsertId;
        } else {
            return error("Unable to obtain last insert ID");
        }
    }

}


