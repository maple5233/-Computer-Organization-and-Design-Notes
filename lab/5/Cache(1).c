#include <stdio.h>
#include <time.h>

#define ARRAY_MIN (1024)	//min cache 4K
#define ARRAY_MAX (1024*1024*8)	//max cache 64M

int x[ARRAY_MAX];	//Array going to stride through

double get_seconds()	//Routine to read time in seconds
{
	__time64_t ltime;
	_time64(&ltime);
	return (double)ltime;
}

int label(int i)	//For print
{
	if(i<1e3)
		printf("%ldB\t",i);
	else
		if(i<1e6)
			printf("%ldK\t",i/1024);
		else
			if(i<1e9)
				printf("%ldM\t",i/1048576);
			else
				printf("%ldG\t",i/1073741824);
	return 0;
}

int main(int argc, char* argv[])
{
	int register nextstep, i, index, stride;
	int csize;
	double steps, tsteps;
	double loadtime, lastsec, sec0, sec1, sec;	//time

	printf("\t");
	for(stride=1;stride<=ARRAY_MAX/2;stride=stride*2)
		label(stride*sizeof(int));
	printf("\n");

	for(csize=ARRAY_MIN;csize<=ARRAY_MAX;csize=csize*2)	//Main loop
	{
		label(csize*sizeof(int));	//Print Cache size this loop
		for(stride=1;stride<=csize/2;stride=stride*2)
		{
			//Lay out path of memory references in array
			for(index=0;index<csize;index+=stride)
				x[index]=index+stride;	//Point to next
			x[index-stride]=0;

			//Wait for timer to roll over
			lastsec=get_seconds();
			do sec0=get_seconds();
			while(sec0==lastsec);

			steps=0.0;
			nextstep=0;
			sec0=get_seconds();
			
			//Walk through path in array for 20 seconds
			do
			{
				for(i=stride;i!=0;i--)
				{
					nextstep=0;
					do nextstep=x[nextstep];
					while(nextstep!=0);
				}
				steps+=1.0;
				sec1=get_seconds();
			}
			while((sec1-sec0)<20.0);	//set time is 20, the bigger, the more precise	
			sec=sec1-sec0;

			tsteps=0.0;
			sec0=get_seconds();
			
			//Repeat empty loop to loop substract overhead
			do
			{
				for(i=stride;i!=0;i--)
				{
					index=0;
					do index+=stride;
					while(index<csize);
				}
				tsteps+=1.0;
				sec1=get_seconds();
			}
			while(tsteps<steps);
			sec=sec-(sec1-sec0);
			loadtime=(sec*1e9)/(steps*csize);

			printf("%4.1f\t",(loadtime<0.1)?0.1:loadtime);
		}
		printf("\n");
	}
	system("PAUSE");
	return 0;
}