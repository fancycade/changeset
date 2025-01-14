%%%-----------------------------------------------------------------------------
%%% @author William Fank Thomé [https://github.com/williamthome]
%%% @copyright 2023 William Fank Thomé
%%% @doc Type validator module.
%%% @end
%%%-----------------------------------------------------------------------------
-module(changeset_type_validator).

-export([validate_change/2]).

-include("changeset.hrl").

-callback validate_change(field(), #changeset{}) -> [error()].

validate_change(Field, #changeset{types = Types} = Changeset) ->
    FieldType = maps:get(Field, Types),
    do_validate_change(FieldType, Field, Changeset).

do_validate_change(atom, Field, Changeset) ->
    changeset_atom_validator:validate_change(Field, Changeset);
do_validate_change(binary, Field, Changeset) ->
    changeset_binary_validator:validate_change(Field, Changeset);
do_validate_change(bitstring, Field, Changeset) ->
    changeset_bitstring_validator:validate_change(Field, Changeset);
do_validate_change(boolean, Field, Changeset) ->
    changeset_boolean_validator:validate_change(Field, Changeset);
do_validate_change(float, Field, Changeset) ->
    changeset_float_validator:validate_change(Field, Changeset);
do_validate_change(function, Field, Changeset) ->
    changeset_function_validator:validate_change(Field, Changeset);
do_validate_change({function, Arity}, Field, Changeset) ->
    changeset_function_validator:validate_change({Field, Arity}, Changeset);
do_validate_change(integer, Field, Changeset) ->
    changeset_integer_validator:validate_change(Field, Changeset);
do_validate_change(list, Field, Changeset) ->
    changeset_list_validator:validate_change(Field, Changeset);
do_validate_change(map, Field, Changeset) ->
    changeset_map_validator:validate_change(Field, Changeset);
do_validate_change(pid, Field, Changeset) ->
    changeset_pid_validator:validate_change(Field, Changeset);
do_validate_change(port, Field, Changeset) ->
    changeset_port_validator:validate_change(Field, Changeset);
do_validate_change(record, Field, Changeset) ->
    changeset_record_validator:validate_change(Field, Changeset);
do_validate_change({record, Name}, Field, Changeset) ->
    changeset_record_validator:validate_change({Field, Name}, Changeset);
do_validate_change({record, Name, Size}, Field, Changeset) ->
    changeset_record_validator:validate_change({Field, Name, Size}, Changeset);
do_validate_change(reference, Field, Changeset) ->
    changeset_reference_validator:validate_change(Field, Changeset);
do_validate_change(tuple, Field, Changeset) ->
    changeset_tuple_validator:validate_change(Field, Changeset).
