#!/bin/bash
y_input=`cat sine_square_init|awk '{printf("%g\n", $1)}'`
expect_y=`cat sine_square_init|awk '{printf("%g\n", $2)}'`
iter=0 
for i in $y_input
	do
	iter=$(expr $iter + 1)
	echo $iter
	field=`echo $i | awk '{printf("%g", $1)}'`
	mkdir field.$iter
	cd field.$iter
	cp ../sine_square_init .
	cp ../field.$(expr $iter - 1 )/task$(expr $iter - 1).out/m000007.ovf .
	index=1
	for j in $expect_y
	do
		#echo $index	 $iter
		if [ $index -eq $iter ]
		then
		expectation=`echo $j | awk '{printf("%g", $1)}'`
		#echo $expectation
		fi
		#echo $expectation
		index=$(expr $index + 1)
	done

	cat <<-EOF >task$iter.mx3	
	//Define Bounding Box

	SetGridsize(550/2.5, 200/2.5, 5/2.5)
	SetCellsize(2.5e-9, 2.5e-9, 2.5e-9)

	//Material Parameters

	alpha = 0.02
	Msat  = 477e3
	Aex   = 1.05e-11

	//Define Geometry

	a:=rect(550e-9,50e-9).transl(0,-75e-9,0)
	b:=rect(70e-9,150e-9).transl(200e-9,25e-9,0)
	c:=rect(70e-9,150e-9).transl(-200e-9,25e-9,0)
	d:=a.add(b)
	e:=d.add(c)
	
	// Set the integrator
	SetSolver(4) //corresponding to RK4th method

	setgeom(e)

	//define initial magnetisation

	defRegion(1, xrange(-inf, -25e-9))
	defRegion(2, xrange(-25e-9, 25e-9))
	defRegion(3, xrange(25e-9, inf))

	m.SetRegion(1, uniform(1,0.1,0))
	m.SetRegion(2, uniform(0,-1,0))
	m.SetRegion(3, uniform(-1,0.1,0))

	m.LoadFile("m000007.ovf")
	//removes surface charges
	BoundaryRegion := 0
	MagLeft        := 1
	MagRight       := -1
	//ext_rmSurfaceCharge(BoundaryRegion, MagLeft, MagRight)

	B0:=$field
	expectation:=$expectation 
	TableAdd(B_ext)
	TableAddVar(B0, "B0", "Oe")
	TableAddVar(expectation, "Expect","u.a.")

	f:= 500e6
	//define mask variables
	n1:=-0.95
	n2:=1
	n3:=-0.75
	n4:=0.45
	n5:=-0.25
	n6:=0.75
	n7:=-1.0
	n8:=0.5
	Bc:=0.001
	DH:=0.001

	B_ext = vector((Bc + DH*B0*n1 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n2 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n3 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n4 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n5 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n6 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n7 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)

	B_ext = vector((Bc + DH*B0*n8 )*sin(2*pi*f*t), 0,0)
	run(0.5e-9)
	tablesave()
	save(m)


	EOF
	
	mumax3.exe task$iter.mx3 

cd ..

done

