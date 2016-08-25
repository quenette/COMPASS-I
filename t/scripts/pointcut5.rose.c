
typedef void (TestPrototype) (void);
typedef struct {
	int x[30];
} TestClass;

void test1(void)
{
	int *x = ((TestClass *) pointcut_ptr())->x;
	int i;

	for (i = 1; i <= 10; i += 1) {
		x[2 * i] = x[2 * i + 1] + 2;
	}
}

void test2(void)
{
	int *x = ((TestClass *) pointcut_ptr())->x;
	int i;

	for (i = 1; i <= 10; i += 1) {
		x[2 * i + 3] = x[2 * i] + i;
	}
}

void body1();

int main(int argc, char *argv[])
{
	TestClass *obj = malloc(sizeof(TestClass));

	coInit(&argc, &argv, coStaticWeave | coStaticAdvice);

	advice_object(body1, TestPrototype, obj, test1, coAdviceAppend);
	advice_object(body1, TestPrototype, obj, test2, coAdviceAppend);

	/* Set some initial values */
	memset(obj->x, 0, sizeof(int) * 30);
	obj->x[2] = 3;

	coWeave();
	body1(obj);

	/* dump the result */
	printf("x[21] = %d\n", obj->x[21]);

	coFinalise();
	return 0;
}

void body1(TestClass * obj)
{
	pointcut_object(TestPrototype, obj);
}
