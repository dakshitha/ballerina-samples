import ballerina/http;
 
http:JwtValidatorConfig config = {
   issuer: "https://api.asgardeo.io/t/mycomp/oauth2/token",
   audience: "XerCfooSSk8lts5gXPPQPEvPKeQa",
   signatureConfig: {
       jwksConfig: {
           url: "https://api.asgardeo.io/t/mycomp/oauth2/jwks"
       }
   }
};
 
listener http:Listener securedEP = new (9090,
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
           jwtValidatorConfig: config
       }
   ]
}
service / on securedEP {
 
   resource function get greeting(string name) returns string {
       return "\n * * * * * " + "Hey there, " + name + "! * * * * *\n\n"
       + "* * * * * You just accessed a secure message * * * * * ! \n\n";
   }
}
