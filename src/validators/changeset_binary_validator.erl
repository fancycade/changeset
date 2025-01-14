%%%-----------------------------------------------------------------------------
%%% @author William Fank Thomé [https://github.com/williamthome]
%%% @copyright 2023 William Fank Thomé
%%% @doc Binary validator module.
%%% @end
%%%-----------------------------------------------------------------------------
-module(changeset_binary_validator).

-behaviour(changeset_type_validator).

-export([validate_change/2]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

validate_change(Field, Changeset) ->
    changeset_validator:validate_change(Changeset, Field, fun
        (Binary) when is_binary(Binary) ->
            [];
        (_) ->
            [ changeset:error( Field
                             , <<"must be a binary">>
                             , #{validation => is_binary} ) ]
    end).

% Test

-ifdef(TEST).

-include("changeset.hrl").

validate_change_test() ->
    [ { "Should be valid"
      , ?assert(changeset:is_valid(validate_change(foo, #changeset{changes = #{foo => <<>>}})))
      }
      % TODO: Move missing field test to validator module
    , { "Should be valid when field is missing"
      , ?assert(changeset:is_valid(validate_change(foo, #changeset{changes = #{}})))
      }
    , { "Should be invalid when field is not a binary"
      , ?assertNot(changeset:is_valid(validate_change(foo, #changeset{changes = #{foo => bar}})))
      }
    ].

-endif.
