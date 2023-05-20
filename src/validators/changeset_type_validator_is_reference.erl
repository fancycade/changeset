%%%-----------------------------------------------------------------------------
%%% @author William Fank Thomé [https://github.com/williamthome]
%%% @copyright 2023 William Fank Thomé
%%% @doc Reference validator module.
%%% @end
%%%-----------------------------------------------------------------------------
-module(changeset_type_validator_is_reference).

-behaviour(changeset_type_validator).

-export([validate_change/2]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

validate_change(Field, Changeset) ->
    changeset_validator:validate_change(Changeset, Field, fun
        (Reference) when is_reference(Reference) ->
            [];
        (_) ->
            [ changeset:error( Field
                             , <<"must be a reference">>
                             , #{validation => is_reference} ) ]
    end).

% Test

-ifdef(TEST).

-include("changeset.hrl").

validate_change_test() ->
    [ { "Should be valid"
      , ?assert(changeset:is_valid(validate_change(foo, #changeset{changes = #{foo => list_to_ref("#Ref<0.4192537678.4073193475.71181>")}})))
      }
    , { "Should be invalid when field is not a reference"
      , ?assertNot(changeset:is_valid(validate_change(foo, #changeset{changes = #{foo => bar}})))
      }
    ].

-endif.