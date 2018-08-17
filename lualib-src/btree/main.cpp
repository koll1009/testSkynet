#include "bTask.h"

int main(int argc, const char* argv[])
{
	bTask* task = new bTask(NULL);
	task->Init("Map.json");
}