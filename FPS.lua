local begin_running_time = GetRunningTime() local begin_running_time = GetRunningTime()--FPS压枪宏 v0.1  MountCloud @2019 www.mountcloud.org

--介绍：技术不行，啥都白扯。本宏的开发环境是G502，适用于具有G键、DPI+、DPI-、前进键、G9键这几个键。

--		宏默认为关闭状态，需要手动启动和关闭。

--		说是导入时需要【设为永久性配置文件】，否则不生效，这个我没测过，反正我一直都是永久的。

--		说是导入时需要【设为永久性配置文件】，否则不生效，这个我没测过，反正我一直都是永久的。



--主要功能：

--		1：可自由开启、关闭宏

--		2：可以调节压枪的力度

--		3：可以在压枪后复原鼠标位置



--档位：

--		3：最高档是根据AK调的

--		2：中档是根据M4调的（默认的）

--		1：最低档是根据冲锋枪调的



--按钮介绍：

--		大写锁定=锁定时开启压枪、关闭锁定时关闭压枪。

--		DPI+=上调一个档位，档位越大，压枪力度越高

--		DPI-=下降一个档位，档位越小，压枪力度越低

--		前进键=开启鼠标复位，就是压枪之后鼠标自动恢复到压枪之前的位置

--		G9键=配置复位键，用于还原成默认配置的，默认配置是：关闭压枪、关闭鼠标复位、默认2档。







--CONFIGS----------------------------------------------------------------------------------
--脚本名字


local scriptName = "MountCloud_SCRIPT"

--是否开启 默认false，进入游戏之后再手动开启

local state = false

--是否打印日志

local showLog = true


local iNDEXXXX=1.2
local forcePlus=0
local forcePlusFist2=6

--开启键，我的鼠标有G键，G键是6

local openLock = "capslock"
--local openLock = 6
--触发脚本的按键 左键是1

--压枪强度，这个是个数组，可以看成档位，值越大压枪力度就越大

local clickBtn = 1

local force = {}

--force[1]= {["force"]=1.5,["threshold"]=100,["increment"]=1.2}

--force[2]= {["force"]=4,["threshold"]=160,["increment"]=2.2}

--force[3]= {["force"]=6,["threshold"]=200,["increment"]=3.2}

force[1]= {["force"]=1.0,["threshold"]=160,["increment"]=0.5}

force[2]= {["force"]=2.4,["threshold"]=200,["increment"]=1.4}


--压枪默认强度档位使用第二个

local forceIndex = 2

--压枪档位向低调节,越低力度越小

local forceIndexDnBtn4 = 4

--压枪档位向高调节，越高力度越大

local forceIndexOnBtn5 = 5



--压枪间隔

local sleepTime = 15



--记录已经压枪的值


local runRorce = 0


--鼠标是否复位

local resetPointState = false

--复位开关按键 G键旁边两个键前边的键

local resetPointBtn = 7

--复位的距离百分比

local resetPointScale = 1







--记录压枪坐标

local startY = 0

local endY = 0



--复位配置按键，防止忘了调节了啥配置

local resetConfigBtn = 9



local LianDian=0
local Gap=0
local move = 0
--------------------------------------------------------------
local KEY_MAP = {
    Left_Btn =  1,
    Right_Btn =  2,
    Middle_Btn =  3,
    G4_Btn =  4,
    G5_Btn =  5,
    G6_Btn =  6,
    G7_Btn =  7,
    G8_Btn =  8,
    G9_Btn =  9,
}

local KEY_NAME_MAP = {
    [1] = "Left_Btn",
    [2] = "Right_Btn",
    [3] = "Roll_Btn",
    [4] = "G4_Btn",
    [5] = "G5_Btn",
    [6] = "G6_Btn",
    [7] = "G7_Btn",
    [8] = "G8_Btn",
    [9] = "G9_Btn",
}

local MOUSE_KEY_STATE = {
    Pressed = 1,
    Released = 2,
}
local Handler = {}
local Handler2 = {}

--FUNCTIONS----------------------------------------------------------------------------------

--开启左键的事件报告


EnablePrimaryMouseButtonEvents(true); 
--总事件

function OnEvent(event, arg)

	--打印事件和参数

	log("event=%s,arg=%s", event, arg)



	--判断是不是开关鼠标复位

	if(event == "MOUSE_BUTTON_PRESSED" and arg == resetPointBtn) then

		if(resetPointState == true) then

			resetPointState = false

			log("resetPoint close")

		else

			resetPointState = true

			log("resetPoint open")

		end

		

		return

	end



	--判断是不是开关鼠标复位

	if(event == "MOUSE_BUTTON_PRESSED" and arg == resetConfigBtn) then

		resetConfig()

	end



	--切换档位，向低档位调节

	if(event == "MOUSE_BUTTON_PRESSED" and arg == 4) then

		setForceIndex(forceIndex-1)
		LianDian = 1

	end



	--切换档位，向高档位调节

	if(event == "MOUSE_BUTTON_PRESSED" and arg == 5) then

		setForceIndex(forceIndex+1)
		LianDian = 1

	end

    
	--连点开关

	if(event == "MOUSE_BUTTON_PRESSED" and arg == 6) then
		
		 --LianDian=LianDian+1
			LianDian = 0
log("liandian%d",LianDian)

	end




	--开始压枪

	if(event == "MOUSE_BUTTON_PRESSED" and arg == clickBtn and IsKeyLockOn(openLock)and LianDian == 1) then

		beginMove()

	end


-----------------------------------------------------------------------------------
    
	-- 配置文件激活
    if (event == "PROFILE_ACTIVATED") then
        OutputLogMessage("PROFILE_ACTIVATED\n")
    -- 配置文件检测
    elseif (event == "PROFILE_DEACTIVATED") then
        OutputLogMessage("PROFILE_DEACTIVATED\n")
    -- 鼠标事件按下
    elseif (event == "MOUSE_BUTTON_PRESSED" and LianDian == 0  and IsKeyLockOn(openLock)) then
		OutputLogMessage("MOUSE_BUTTON_PRESSED\n")
        if KEY_NAME_MAP[arg] and Handler[KEY_NAME_MAP[arg]] then
			--OutputLogMessage("KEY_NAME_MAP[arg] and Handler[KEY_NAME_MAP[arg]] \n")
            Handler2[KEY_NAME_MAP[arg]](MOUSE_KEY_STATE.Pressed)
        end
    -- 鼠标事件放开
    elseif (event == "MOUSE_BUTTON_RELEASED"  and LianDian == 0  and IsKeyLockOn(openLock)) then
        if KEY_NAME_MAP[arg] and Handler[KEY_NAME_MAP[arg]] then
            Handler2[KEY_NAME_MAP[arg]](MOUSE_KEY_STATE.Released)
        end
    end
----------------------------------------------------------------------------------Left_Btn
    

end



--是否是偶数
function IsOuNumber(num)
    local num1,num2=math.modf(num/2)--返回整数和小数部分
    if(num2==0)then
        return true
    else
        return false
    end
end



--返回需要执行的压枪力度

function getForce(time)
	log("result force is %s time is %s",result, time)
	local forceIncrement = force[forceIndex].increment

	--if(time>300) then
		--forceIncrement = forceIncrement/1.25
	--end	
	--if(time>800) then
		--forceIncrement = forceIncrement/1
	--end	

	if(isNull(time) or isNull(forceIncrement)) then

		return force[forceIndex].force

	end

	--增量方式
	local incrementMul = time / 100
	--local nowIncrement = incrementMul * forceIncrement/iNDEXXXX
	local nowIncrement = forceIncrement/iNDEXXXX
	local result = (force[forceIndex].force + nowIncrement)
	 --result =forcePlus +result
	log("result force is %s time is %s",result, time)

	return result

end



--返回需要压枪的阈值

function getThreshold()

	return force[forceIndex].threshold

end



--执行压枪

function beginMove()
if not IsMouseButtonPressed(3) and LianDian==0 then
OutputLogMessage("Left mouse button is pressed.\n");
PressMouseButton(3)
end


	local x,y = getPoint()

	local hittime = 0

	

	local runTimeStart = GetRunningTime()

	--记录开始的坐标

	startY = y

	--此步骤就是鼠标按下执行，放下就跳出此块

	repeat

		--判断是不是已经超过压枪的阈值

		if(runRorce < getThreshold()) then


			log("run="..runRorce)
log("result force is %s time is================================= %s",result, time)


			--设置间隔

			Sleep(sleepTime)

			local runTime =  GetRunningTime() - runTimeStart

			local tempForce = getForce(runTime)

			--记录压枪的值

			runRorce = runRorce+tempForce

			--执行
			hittime = hittime+1
--------------------
			if(hittime<2) then
				tempForce = tempForce+forcePlusFist2
	        end

        
----------------------------------------------------

			MoveMouseRelative(0,tempForce)

		end

	until not IsMouseButtonPressed(clickBtn)

if  IsMouseButtonPressed(3) and LianDian==0 then
OutputLogMessage("Left mouse button is pressed.\n");
ReleaseMouseButton(3)
end


	x,y = getPoint()

	endY = y

	log("startY=%s,endY=%s,range=%s",startY,endY,endY-startY)



	--是否需要复位鼠标位置

	if(resetPointState) then

		local resetRang = endY-startY

		resetPoint(runRorce)

	end

	--重置记录的压枪的值

	runRorce = 0



end




--复位鼠标

function resetPoint(range)

	--求出复位的值

	local rangeScale = range * resetPointScale

	--复位时的运行速度一定要快，为啥要移动回去呢，因为防止作弊检测

	local resetSleepTime = 1



	local x,y = getPoint()	



	local runRange = 0

	while(runRange < rangeScale)

	do

		runRange = runRange + getForce()

		local resetForce = getForce() * -1

		MoveMouseRelative(0,resetForce)

		Sleep(resetSleepTime)

	end

end



--调节档位

function setForceIndex(findex)

	if(findex<1) then

		findex = 1	
		log("findex==1")

	end

	if(findex > #force) then
		findex = #force



	log("switch forceIndex=%s,force=%s,threshold=%s",forceIndex,getForce(),getThreshold())

end



	forceIndex = findex

--复位需要复位的配置

	end
function resetConfig()

	log("reset config")

	forceIndex = 2

	state = false

	resetPointState = false

end





--返回鼠标的坐标

function getPoint()

	return GetMousePosition()

end



--原来的日志函数太长了

function log(str,...)

	if(showLog) then

		--log("result force is %s time is %s",result, time)OutputLogMessage(scriptName.."-[INFO]-"..str.."\n", ...)	

	end

end



--判断是否为空

function isNull(arg)

	if(arg == nil) then

		return true

	end

	return false

end
















function Handler.Left_Btn( m_state )
	local end10=0
			local diviation = 10
		local T=0
    local KEY = KEY_MAP.Left_Btn
    local begin_running_time = GetRunningTime()
    if (m_state == MOUSE_KEY_STATE.Pressed) then
        local now_running_time = GetRunningTime()
        -- 1000ms内点击
		OutputLogMessage("FUNCTION ON!!!!!!!!!!!!!!!!!!!!!! \n")
		Sleep(10)

        while (IsMouseButtonPressed(1)) do
			------------------------------
			Sleep(15)
			if(end10>5) then
MoveMouseRelative(0.8*diviation*T,-1*T*diviation)
    			--[ 使用 break 语句终止循环 --]      OutputLogMessage("break 1 \n")
    			break
  			end
			---------------------------------
			Sleep(20)
            if (IsMouseButtonPressed(1)~=true ) then
                -- PressMouseButton(KEY)
			end10=11
			OutputLogMessage("PressMouseButton 1 \n")
				
            else
				MoveMouseRelative(-0.8*diviation,diviation)
				T=T+1
                ReleaseMouseButton(KEY)
			  Sleep(20)
			
                PressMouseButton(KEY)
			  end10 = end10+1
			 --ReleaseMouseButton(KEY)
				--beginMove()
            end
           
            now_running_time = GetRunningTime()
			------------------------------
			Sleep(20)
			if(m_state == MOUSE_KEY_STATE.Released) then
MoveMouseRelative(0.8*diviation*T,-1*T*diviation)
    			--[ 使用 break 语句终止循环 --]      OutputLogMessage("break 1 \n")
    			break
  			end
			---------------------------------

        end
    elseif (m_state == MOUSE_KEY_STATE.Released) then
		MoveMouseRelative(0.8*diviation*T,-1*T*diviation)
        ReleaseMouseButton(KEY)
    end
	
end


local xx={5,7,9,9,11,1,1,2,2,2,2,2,2,2}
local yy={9,11,25,29,3,3,3,3,3,3,3,3,3,3}
local huix=10
local huiy = 13
local forceindex=1
function Handler2.Left_Btn( m_state )
	local end10=0
			local diviation = 10
		local T=0
		local huizhong = 0
    local KEY = KEY_MAP.Left_Btn
    local begin_running_time = GetRunningTime()
    if (m_state == MOUSE_KEY_STATE.Pressed) then
        local begin_running_time = GetRunningTime()
        -- 1000ms内点击
		OutputLogMessage("FUNCTION ON!2222222222!!!!!! \n")


for var=1,2,1 do 
MoveMouseRelative(-forceindex*0.85*yy[var],forceindex*yy[var])------------------
T=T+1

Sleep(20)

if (IsMouseButtonPressed(1)) then
	--do nothing
else
	OutputLogMessage("break \n")
	------------
	if (var<=2) then
	MoveMouseRelative(forceindex*1.6*yy[1],-1.8*forceindex*yy[1])
	OutputLogMessage("break111 \n")
Sleep(10)
	else
	MoveMouseRelative(1*T*0.85*huiy,-1*T*huiy)
	end
	------------
	huizhong=1
	break
end

--OutputLogMessage("PressMouseButton !!!!!! \n")

ReleaseMouseButton(KEY)
------------------
if(var==1)
then
   Sleep(35)
else
   Sleep(38)
end
------------------

	OutputLogMessage("PressMouseButton !!!!!! \n")	

   PressMouseButton(KEY) 
	--MoveMouseRelative(-forceindex*xx[var],forceindex*yy[var])------------------
	Sleep(10)


end  


    elseif (m_state == MOUSE_KEY_STATE.Released) then
		--MoveMouseRelative(0.8*diviation*T,-1*T*diviation)
		MoveMouseRelative(1*T*0.85*huiy,-1*T*huiy)
        ReleaseMouseButton(KEY)
Sleep(10)
    end
		if (huizhong==0) then
			MoveMouseRelative(1*T*0.85*huiy,-1*T*huiy)
Sleep(10)
		end
	
end
