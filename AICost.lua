--[[
Author: GIANTS Software, Maxonchis
Contact: https://www.youtube.com/@Maxonchis
		 https://vk.com/engineeringagroteam
Game version: Farming Simulator 22
		 
Description:

Данный скрипт позволяет уменьшить/увеличить стоимость работы наймита путем изменения значения myMultiplier.
Поумолчанию стоимость работы снижена в два раза.

This script allows you to reduce / increase the cost of AI work by changing the value of myMultiplier.
By default, the cost of work is reduced by half.

Подключать скрипт в modDesc.xml вашей карты.
Например:

<extraSourceFiles>
	<sourceFile filename="вашПуть/AICost.lua" />
</extraSourceFiles> 

Include the script in modDesc.xml of your map.
Forexampl:
<extraSourceFiles>
	<sourceFile filename="yourPath/AICost.lua" />
</extraSourceFiles> 
]]

source("dataS/scripts/ai/AISystem.lua")
function AISystem:update(dt)
	local myMultiplier = 2

	for i = #self.jobsToRemove, 1, -1 do
		local job = self.jobsToRemove[i]
		local jobId = job.jobId

		table.removeElement(self.activeJobs, job)
		table.remove(self.jobsToRemove, i)
		g_messageCenter:publish(MessageType.AI_JOB_REMOVED, jobId)
	end

	for _, job in ipairs(self.activeJobs) do
		job:update(dt)

		if self.isServer then
			local price = job:getPricePerMs()

			if price > 0 then
				local difficultyMultiplier = g_currentMission.missionInfo.buyPriceMultiplier

				if GS_IS_MOBILE_VERSION then
					difficultyMultiplier = difficultyMultiplier * 0.8
				end
				
				price = (price * dt * difficultyMultiplier) / myMultiplier

				g_currentMission:addMoney(-price, job.startedFarmId, MoneyType.AI, true)

				local farm = g_farmManager:getFarmById(job.startedFarmId)

				if farm ~= nil and farm:getBalance() + price < 0 then
					self:stopJob(job, AIMessageErrorOutOfMoney.new())
				end
			end
		end
	end
end