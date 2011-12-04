/*!
 * \file ContextFilter.cpp
 * \brief Contex filter.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#include "ContextFilter.h"


ContextFilter::~ContextFilter(void)
{
}

ContextFilter::ContextFilter(char* source, char* KernelName): Filter(source,KernelName)
{

}

ContextFilter::ContextFilter()
{

}
