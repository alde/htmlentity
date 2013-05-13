-module(htmlentity).
-include_lib("eunit/include/eunit.hrl").
-export([decode/1, encode/1]).

%%%%%%
% Module to decode and encode htmlentities in a string.

encode([]) -> [];
encode(String) ->
    encode(String, []).

encode([], Acc) ->
    lists:flatten(lists:reverse(Acc));
encode([H|T], Acc) ->
    encode(T, [[htmlencode(H)] | Acc]).

decode([]) -> [];
decode(String) ->
    decode(String, []).

decode([], Acc) ->
    lists:flatten(lists:reverse(Acc));
decode([H|T], Acc) ->
    case [H] of
        "&" -> {H2, T2} = parse_entity([H|T]),
                decode(T2, [htmldecode(H2) | Acc]);
        _ -> decode(T, [[H] | Acc])
    end.

%%
% Encode a string into htmlentities
htmlencode(Char) ->
    case Char of
        229 -> "&aring;";
        _ -> Char
    end.
%%
% Decode a discovered entity into a string
htmldecode(Entity) ->
    case Entity of
        "&quot;" -> "\"";
        "&amp;" -> "&";
        "&apos;" -> "'";
        "&lt;" -> "<";
        "&gt;" -> ">";
        "&aring;" -> [229]; %"�";
        "&auml;" -> [228]; %"�";
        "&ouml;" -> [246]; %"�";
        "&Aring;" -> [197]; %"�";
        "&Auml;" -> [196]; %"�";
        "&Ouml;" -> [214]; %"�";
        _ -> Entity
    end.

parse_entity(String) ->
    parse_entity(String, []).

parse_entity([], Acc) ->
    {lists:reverse(Acc), []};

parse_entity([H|T], Acc) when [H] == ";" ->
    {lists:reverse([H|Acc]), T};

parse_entity([H|T], Acc) ->
    parse_entity(T, [H|Acc]).

%%
% Tests
decode_test() ->
    ?assert(decode("&quot;foo&quot;") == "\"foo\""),
    ?assert(
        decode(
            "&lt;div&gt;&quot;Hello &amp; welcome!&lt;/div&gt;"
        ) == "<div>\"Hello & welcome!</div>"),
    ?assert(decode("&aring;&auml;&ouml;") == "���"),
    ?assert(decode("&Aring;&Auml;&Ouml;") == "���")
    .

encode_test() ->
    ?assert(encode("�") == "&aring;"),
    ?assert(encode("f�r f�r f�r?") == "f&aring;r f&aring;r f&aring;r?")
    .
