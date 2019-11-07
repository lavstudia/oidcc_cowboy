REBAR = $(shell pwd)/rebar3
APP=oidcc

.PHONY: all ct test clean elvis compile basic_client

all: compile

clean:
	$(REBAR) clean

eunit:
	$(REBAR) eunit
	cp _build/test/cover/eunit.coverdata .

ct:
	$(REBAR) ct

elvis:
	$(REBAR) lint

compile:
	$(REBAR) compile

basic_client_clean:
	make -C example/basic_client clean

basic_client_run:
	make -C example/basic_client run

basic_client:
	basic_client_clean
	basic_client_run