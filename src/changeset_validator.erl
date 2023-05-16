-module(changeset_validator).

-export([validate_change/3, validate_data/3, validate/4]).
-export([validate_is_required/1, validate_is_required/2]).
-export([validate_ok/0, validate_ok/1]).
-export([validate_error/3, validate_errors/2]).

-include("changeset.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

validate_change( Validate
               , Field
               , #changeset{changes = Changes} = Changeset ) ->
    validate(Validate, Field, Changeset, Changes).

validate_data( Validate
             , Field
             , #changeset{data = Data} = Changeset ) ->
    validate(Validate, Field, Changeset, Data).

validate( Validate
        , Field
        , #changeset{ default = Default
                    , errors  = Errors } = Changeset
        , Map ) when is_function(Validate, 1) ->
    case proplists:lookup(Field, Errors) of
        {Field, _} ->
            Changeset;
        none ->
            Value = get_field_value(Field, Map, Default),
            case Validate(Value) of
                ok ->
                    Changeset;
                {ok, #changeset{} = NewChangeset} ->
                    NewChangeset;
                {error, NewErrors} when is_list(NewErrors) ->
                    changeset:push_errors(NewErrors, Changeset);
                {error, Error} ->
                    changeset:push_error(Error, Changeset)
            end
    end.

validate_is_required(Fields) ->
    fun(Changeset) -> validate_is_required(Fields, Changeset) end.

validate_is_required( [Field | T]
                    , #changeset{empty_values = EmptyValues} = Changeset ) ->
    case is_field_value_truthy(Field, Changeset#changeset.changes, EmptyValues) of
        true ->
            validate_is_required(T, Changeset);
        false ->
            case is_field_value_truthy(Field, Changeset#changeset.data, EmptyValues) of
                true ->
                    validate_is_required(T, Changeset);
                false ->
                    Error = validate_error( Field
                                          , <<"is required">>
                                          , #{validation => is_required} ),
                    changeset:fold( [ changeset:pop_change(Field)
                                    , changeset:push_error(Error)
                                    ]
                                  , Changeset )
            end
    end;
validate_is_required([], Changeset) ->
    Changeset.

validate_ok() ->
    ok.

validate_ok(#changeset{} = Changeset) ->
    {ok, Changeset}.

validate_error(Field, Msg, Meta) ->
    {error, do_validate_error(Field, Msg, Meta)}.

validate_errors(Field, Errors) ->
    lists:map( fun({Msg, Meta}) -> do_validate_error(Field, Msg, Meta) end
             , Errors ).

do_validate_error(Field, Msg, Meta) when is_binary(Msg) ->
    {Field, {Msg, Meta}};
do_validate_error(Field, MsgFun, Meta) when is_function(MsgFun, 2) ->
    Msg = MsgFun(Field, Meta),
    do_validate_error(Field, Msg, Meta).

% Field

get_field_value(Field, Map, Default) when is_map(Map) ->
    case maps:find(Field, Map) of
        {ok, Value} ->
            Value;
        error ->
            case Default of
                no_default ->
                    undefined;
                Default when is_function(Default, 0) ->
                    Default()
            end
    end.

is_field_value_truthy(Field, Data, EmptyValues) when is_map(Data) ->
    case maps:find(Field, Data) of
        {ok, Value} ->
            is_truthy(Value, EmptyValues);
        error ->
            false
    end.

% Value

is_falsy(Value, EmptyValues) when is_list(EmptyValues) ->
    lists:member(normalize(Value), EmptyValues).

is_truthy(Value, Payload) ->
    not is_falsy(Value, Payload).

normalize(Value) when is_binary(Value) ->
    string:trim(Value);
normalize(Value) ->
    Value.

% Test

-ifdef(TEST).

validate_is_required_test() ->
    Changes = #changeset{ data    = #{}
                        , changes = #{foo => bar}
                        , fields  = [foo] },
    ValidChanges = validate_is_required([foo], Changes),
    InvalidChanges = validate_is_required([bar], Changes),

    Data = #changeset{ data    = #{foo => var}
                     , changes = #{}
                     , fields  = [foo] },
    ValidData = validate_is_required([foo], Data),
    InvalidData = validate_is_required([bar], Data),

    [ { "Should have valid changes"
      , ?assert(ValidChanges#changeset.is_valid) },
      { "Should have invalid changes"
      , ?assertNot(InvalidChanges#changeset.is_valid) },
      { "Should have valid data"
      , ?assert(ValidData#changeset.is_valid) },
      { "Should have invalid data"
      , ?assertNot(InvalidData#changeset.is_valid) }
    ].

-endif.
