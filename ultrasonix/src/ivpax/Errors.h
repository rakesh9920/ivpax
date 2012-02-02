#pragma once
#ifndef ERRORS_H
#define ERRORS_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include <exception>
#include <cstring>
#include <string>

/* CLASS */
class Error : public std::runtime_error {

public:
	Error(const char * what) : runtime_error(what) {}
};

#endif