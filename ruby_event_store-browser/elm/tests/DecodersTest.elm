module DecodersTest exposing (suite)

import Api exposing (eventDecoder, eventsDecoder)
import Expect
import Json.Decode exposing (list)
import Main exposing (..)
import Route exposing (buildUrl)
import Test exposing (..)


suite : Test
suite =
    describe "Suite"
        [ describe "JSONAPI decoders"
            [ test "events decoder" <|
                \_ ->
                    let
                        input =
                            """
                            {
                            "links": {
                                "last": "/streams/all/head/forward/20",
                                "next": "/streams/all/004ada1e-2f01-4ed0-9c16-63dbc82269d2/backward/20"
                            },
                            "data": [
                                {
                                "id": "664ada1e-2f01-4ed0-9c16-63dbc82269d2",
                                "type": "events",
                                "attributes": {
                                    "event_type": "DummyEvent",
                                    "data": {
                                        "foo": 1,
                                        "bar": 2.0,
                                        "baz": "3"
                                    },
                                    "metadata": {
                                        "timestamp": "2017-12-20T23:49:45.273Z"
                                    }
                                }
                                }
                            ]
                            }
                            """

                        output =
                            Json.Decode.decodeString eventsDecoder input
                    in
                    Expect.equal output
                        (Ok
                            { events =
                                [ { eventType = "DummyEvent"
                                  , eventId = "664ada1e-2f01-4ed0-9c16-63dbc82269d2"
                                  , createdAt = "2017-12-20T23:49:45.273Z"
                                  , rawData = "{\n  \"foo\": 1,\n  \"bar\": 2,\n  \"baz\": \"3\"\n}"
                                  , rawMetadata = "{\n  \"timestamp\": \"2017-12-20T23:49:45.273Z\"\n}"
                                  , correlationStreamName = Nothing
                                  , causationStreamName = Nothing
                                  }
                                ]
                            , links =
                                { next = Just "/streams/all/004ada1e-2f01-4ed0-9c16-63dbc82269d2/backward/20"
                                , prev = Nothing
                                , first = Nothing
                                , last = Just "/streams/all/head/forward/20"
                                }
                            }
                        )
            , test "handles slashes properly in urls" <|
                \_ ->
                    Expect.equal
                        (buildUrl "https://example.org" "resource/uuid")
                        "https://example.org/resource%2Fuuid"
            , test "event decoder" <|
                \_ ->
                    let
                        input =
                            """
                            {
                            "data": {
                                "id": "664ada1e-2f01-4ed0-9c16-63dbc82269d2",
                                "type": "events",
                                "attributes": {
                                    "event_type": "DummyEvent",
                                    "data": {
                                        "foo": 1,
                                        "bar": 3.4,
                                        "baz": "3"
                                    },
                                    "metadata": {
                                        "timestamp": "2017-12-20T23:49:45.273Z"
                                    },
                                    "correlation_stream_name": "$by_correlation_id_a7243789-999f-4ef2-8511-b1c686b83fad",
                                    "causation_stream_name": "$by_causation_id_664ada1e-2f01-4ed0-9c16-63dbc82269d2"
                                }
                            }
                            }
                            """

                        output =
                            Json.Decode.decodeString eventDecoder input
                    in
                    Expect.equal output
                        (Ok
                            { eventType = "DummyEvent"
                            , eventId = "664ada1e-2f01-4ed0-9c16-63dbc82269d2"
                            , createdAt = "2017-12-20T23:49:45.273Z"
                            , rawData = "{\n  \"foo\": 1,\n  \"bar\": 3.4,\n  \"baz\": \"3\"\n}"
                            , rawMetadata = "{\n  \"timestamp\": \"2017-12-20T23:49:45.273Z\"\n}"
                            , correlationStreamName = Just "$by_correlation_id_a7243789-999f-4ef2-8511-b1c686b83fad"
                            , causationStreamName = Just "$by_causation_id_664ada1e-2f01-4ed0-9c16-63dbc82269d2"
                            }
                        )
            ]
        ]
