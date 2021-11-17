%option noyywrap
/* avoid dependency with library fl */

%{ 
#include "y.tab.h"
#include "Table_des_symboles.h"
#include "Attribute.h"
#include <stdio.h>

%} 
%% 

"="                      { return EQ;}

"+"                      { return PLUS;}
"-"                      { return MOINS;}
"*"                      { return STAR;}
"/"                      { return DIV;}
"||"                     { return OR;}
"&&"                     { return AND;}
"!"                      { return NOT;}

"=="                     { return EQUAL;}
"!="                     { return DIFF;}
"<"                      { return INF;}
">"                      { return SUP;}

"("                      { return PO;}
")"                      { return PF;}
"{"                      { return AO;}
"}"                      { return AF;}

"int"                    { return TINT;}

"return"                 { return RETURN;}
"void"                   { return VOID;}
"if"                     { return IF;}
"else"                   { return ELSE;}
"while"                  { return WHILE;}

"."                      { return DOT;}
"->"                     { return ARR;}

";"                      { return PV;}
","                      { return VIR;}


[0-9]+                   { yylval.att = new_attribute();
	        	   yylval.att -> int_val =  atoi (yytext);
                           return NUM; }
[A-Za-z][A-Za-z0-9]*     { yylval.att = new_attribute();
                           yylval.att -> name = string_to_sid(yytext);
		           return ID; }
[ \t\n]                   { /* on avale sans rendre la main */; }
