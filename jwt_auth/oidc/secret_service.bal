import ballerina/http;
import ballerina/jwt;
import ballerina/regex;
import ballerina/io;

http:JwtValidatorConfig jwtConfig = {
   issuer: "https://api.asgardeo.io/t/mycomp/oauth2/token",
   audience: "XerCfooSSk8lts5gXPPQPEvPKeQa",
   signatureConfig: {
       jwksConfig: {
           url: "https://api.asgardeo.io/t/mycomp/oauth2/jwks"
        }
   }
};

listener http:Listener securedEP2 = new (8080,
    secureSocket = {
    key: {
        certFile: "./resources/public.crt",
        keyFile: "./resources/private.key"
    }
}
);

@http:ServiceConfig {
    auth: [
        {
            jwtValidatorConfig: jwtConfig
        }
    ]
}
service / on securedEP2 {

    resource function get greeting(string name) returns string {
        return "\n * * * * * " + "Hey there, " + name + "! * * * * *\n\n"
       + "* * * * * You just accessed a secure message * * * * * ! \n\n";
    }

    @http:ResourceConfig {
               auth: [
            {
                jwtValidatorConfig: config,
                scopes: ["secret_code"]
            }
        ]
    }
    resource function get code(@http:Header {name: "Authorization"} string token, string name) returns string|error {

        string jwt = regex:replace(token, "Bearer", "");
        jwt = jwt.trim();
        io:println(jwt);
        [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwt);
        io:println(payload);
        
        string user_email = check payload.get("email").ensureType(string);
        string user_dob = check payload.get("birthdate").ensureType(string);

        return "Hi, " + name + "!\n\nYour secret code is your email + date of birth: " + user_email + user_dob + "\n\n" 
        + "You just accessed a secure message! \n\n";
    }
}
