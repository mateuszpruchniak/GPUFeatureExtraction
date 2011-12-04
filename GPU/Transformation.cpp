/*!
 * \file Transformation.cpp
 * \brief Color transformation class.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#include "Transformation.h"

Transformation::~Transformation(void)
{
}

Transformation::Transformation(char* source, char* KernelName): ContextFreeFilter(source,KernelName)
{

}
