




------set values -----

magnet_dia=.75

coil_OD=1.4825
turns=144--71.62 --actually 144
coil_width=.413

current=6.0

coilsets=6
extra_magnets=2

---------------------

coil_offset=0

buffer=.15625

increment = 1
startpos=0
endpos=0

extraarc=endpos

coil_pitch=coil_width+.03125
magnet_length=coil_pitch*3*.8
magnet_length=1.125
coil_ID=magnet_dia+2*buffer+coil_offset
coil_OD=coil_OD+coil_offset
--amplitude=1.15*turns 

AWG=24 --doesn't affect calculations

wire_dia=0.005*(92^((36-AWG)/39))*25.4
phase=120



project = "Linear Motor"
outfile = project .. "_results.csv"
start_time = date()


showconsole()
mydir="./"

--clearconsole()


-------------------------------------------------
-- Main program
-------------------------------------------------

--newdocument(0) --new magnetics document 
--mi_probdef(0,inches,axi,1e-008)




handle = openfile(outfile, "w")		-- overwrite old results file!
write(handle, "\nInvestigating forces on a linear motor. \n")
write(handle, "Start time: ", start_time, "\n" )

closefile(handle)

--Amount the mover translates for profile generation
nmax=(endpos-startpos)/increment

for n=0,nmax do


offset=startpos+(increment*n)
extraarc=offset+2



open(mydir .. "axi.fem")
mi_saveas(mydir .. "temp.fem")


pitchlength=coil_pitch*3
totallength=pitchlength*coilsets


	


--mi_addmaterial("materialname", mu x, mu y, H c, J, Cduct, Lam d, Phi hmax, lam fill, LamType, Phi hx, Phi hy),NStrands,WireD

mi_addmaterial('Air',1,1,0,0,0,0,0,1,0,0,0);
--mi_addmaterial('18 AWG',1,1,0,0,58,0,0,1,3,0,0,1, 1.02396529684335);
--mi_addmaterial('20 AWG',1,1,0,0,58,0,0,1,3,0,0,1, 0.812049969500513);
mi_addmaterial('wire',1,1,0,0,58,0,0,1,3,0,0,1, wire_dia);
mi_addmaterial('NdFeB 40 MGOe',1.049,1.049,979000,0,0.667,0,0,1,0,0,0,0,0);


--mi_addboundprop("propname", A0, A1, A2, Phi, Mu, Sig, c0, c1, BdryFormat)

mi_addboundprop("ABC", 0, 0, 0, 0, 0, 0, 1/(uo*4*inch) , 0, 2)



--add top and bottom arc nodes and connect everything
mi_addnode(0,totallength/2+1+extraarc)
mi_addnode(0,-1*(totallength/2+1+extraarc))
mi_addarc(0,-1*(totallength/2+1+extraarc),0,totallength/2+1+extraarc,180,2)
mi_addsegment(0,-1*(totallength/2+1+extraarc),0,totallength/2+1+extraarc)



--create node label and set to "Air"
mi_addblocklabel(totallength/2,0)
mi_selectlabel(totallength/2,0)
mi_setblockprop("Air", 0, .05, 0, 0,0 ,0 )
mi_clearselected()

--Set arc segment boundary conditions to ABC
mi_selectarcsegment(0,totallength/2+1)
mi_setarcsegmentprop(2, "ABC", 0, 0)
mi_clearselected()

mi_zoomnatural()


--create magnet segments


for var=1-extra_magnets/2,(coilsets+extra_magnets/2) do

	set=var-coilsets*.5
	y_dim=set*pitchlength-pitchlength*.5
	
	mi_addnode(magnet_dia/2,set*pitchlength-pitchlength*.5+magnet_length*.5+offset)
	mi_addnode(magnet_dia/2,set*pitchlength-pitchlength*.5-magnet_length*.5+offset)
	mi_addnode(0,set*pitchlength-pitchlength*.5+magnet_length*.5+offset)
	mi_addnode(0,set*pitchlength-pitchlength*.5-magnet_length*.5+offset)
	
	mi_addsegment(0,set*pitchlength-pitchlength*.5+magnet_length*.5+offset,magnet_dia/2,set*pitchlength-pitchlength*.5+magnet_length*.5+offset)
	mi_addsegment(magnet_dia/2,set*pitchlength-pitchlength*.5-magnet_length*.5+offset,magnet_dia/2,set*pitchlength-pitchlength*.5+magnet_length*.5+offset)
	mi_addsegment(0,set*pitchlength-pitchlength*.5-magnet_length*.5+offset,magnet_dia/2,set*pitchlength-pitchlength*.5-magnet_length*.5+offset)
	
	
	mi_addblocklabel(magnet_dia/4,set*pitchlength-pitchlength*.5+offset)
	mi_selectlabel(magnet_dia/4,set*pitchlength-pitchlength*.5+offset)
	
	--set angle for magnetism to alternate +90 and -90
	angle=90-180*mod(var,2)
	
	mi_setblockprop("NdFeB 40 MGOe", 0, .05, 0, angle, 7, 0)
	mi_clearselected()
	mi_zoomnatural()
	
end
	
	
for var=1,coilsets do

set=var-coilsets*.5
	y_dim=set*pitchlength-pitchlength*.5
	
	--create the coils	
	for coilnum=-1,1,1 do
	
		--add nodes
		mi_addnode(coil_ID/2,y_dim+coil_width/2+coil_pitch*coilnum)
		mi_addnode(coil_OD/2,y_dim+coil_width/2+coil_pitch*coilnum)
		mi_addnode(coil_ID/2,y_dim-coil_width/2+coil_pitch*coilnum)
		mi_addnode(coil_OD/2,y_dim-coil_width/2+coil_pitch*coilnum)
		
		--connect the dots
		mi_addsegment(coil_ID/2,y_dim+coil_width/2+coil_pitch*coilnum, coil_OD/2,y_dim+coil_width/2+coil_pitch*coilnum)
		mi_addsegment(coil_ID/2,y_dim-coil_width/2+coil_pitch*coilnum, coil_OD/2,y_dim-coil_width/2+coil_pitch*coilnum) 
		mi_addsegment(coil_OD/2,y_dim+coil_width/2+coil_pitch*coilnum, coil_OD/2,y_dim-coil_width/2+coil_pitch*coilnum)
		mi_addsegment(coil_ID/2,y_dim+coil_width/2+coil_pitch*coilnum, coil_ID/2,y_dim-coil_width/2+coil_pitch*coilnum)
		
		mi_addblocklabel((coil_OD/2+coil_ID/2)/2,y_dim+coil_pitch*coilnum)
		mi_selectlabel((coil_OD/2+coil_ID/2)/2,y_dim+coil_pitch*coilnum)	
	
		mi_setblockprop('wire', 0, .05, "Coil", 0, coilnum+2-3*(mod(var,2)-1), 200)
		mi_clearselected()
		mi_zoomnatural()
	

	end
	
		

end


mi_saveas(mydir .. "temp.fem")


mi_seteditmode("group")
	
	mi_clearselected()
    
--for phase=0,330,30 do
for phase=90,90,30 do
		
		--define circuit
		mi_addcircprop("CoilA", sin(rad(phase))*current, 1)
		mi_addcircprop("CoilB", sin(rad(phase+60))*current, 1)
		mi_addcircprop("CoilC", sin(rad(phase+120))*current, 1)

		--turns_a=sin(rad(phase))*amplitude
		--turns_b=sin(rad(phase+60))*amplitude
		--turns_c=sin(rad(phase+120))*amplitude


			handle = openfile(outfile,"a")
		--	write(handle,"\nPhase,",phase,"\nAmplitude,",amplitude,"\nCurrent,",current,"\nTurns A,",turns_a,"\nTurns B,",turns_b,"\nTurns C,",turns_c,"\n")
			closefile(handle)

		

		groupnum=1
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilA", 0, groupnum, turns)
		mi_clearselected()

		groupnum=2
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilB", 0, groupnum, turns)
		mi_clearselected()

		groupnum=3
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilC", 0, groupnum, turns)
		mi_clearselected()

		groupnum=4
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilA", 0, groupnum, -1*turns)
		mi_clearselected()

		groupnum=5
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilB", 0, groupnum, -1*turns)
		mi_clearselected()

		groupnum=6
		mi_selectgroup(groupnum)
		mi_setblockprop('wire', 0, .05, "CoilC", 0, groupnum, -1*turns)
		mi_clearselected()




			handle = openfile(outfile,"a")
			--write(handle,"\nPosition, Force,B1,B2\n")
			closefile(handle)




		
			mi_analyze(1)
			mi_loadsolution()
			mo_groupselectblock(7)
			fz=mo_blockintegral(19)/4.44822162
			
			A, B1, B2, Sig, E, H1, H2, Je, Js, Mu1, Mu2, Pe, Ph = mo_getpointvalues(0.625,6)

			
			
			print("Force: ",fz,"lbs", " B1: ",B1," B2: ",B2)

			handle = openfile(outfile,"a")
			--write(handle,offset,",", fz,",",B1,",",B2, "\n")
			closefile(handle)
			
		




--mo_close()
end

mi_close()
end


	handle = openfile(outfile,"a")
	write(handle,"End Time: ",date())
	closefile(handle)

