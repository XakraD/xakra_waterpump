Config = {}

Config.KeyPump = 0xA1ABB953 -- G

Config.ProgressbarColor = '#0A4F05' -- VORP progress bar color

Config.TimePumpWater = 20000    -- Time to pump water

Config.EmptyBottle = 'empty_bottle' -- Name of the empty bottle (to pump water/item that returns you when drinking water)
Config.Water = 'water'  -- Name of the water items

Config.DrinkingWater = true -- Enable or disable drink water (VORP METABOLISM)
Config.Thirst = 200 -- Amount of thirst that will make you drink the water
Config.ProbabilityBottle = 25   -- X/100 Probability of returning an empty bottle when consuming water

Config.NotifyMetabolism = true  -- Enable or disable notifications and effects when thirsty or hungry (VORP METABOLISM)

Config.Texts = {
    -- WATER PUMP
    ['Prompt'] = 'Bombear',
    ['ObjectPump'] = 'Bomba de agua',
    ['Pumping'] = 'Bombeando...',
    ['AddWater'] =  'Has bombeado: ~t6~', 
    ['NotEmptyBootle'] =  'Necesitas más botellas vacías',
    ['Water'] =  'Agua', 
    ['FullInventory'] =  'No puedes llevar más agua', 

    -- INPUT
    ['Quantity'] = 'Cantidad',
    ['OnlyNumber'] = 'Solo números',
    ['Button'] =  'Aceptar',
    ['PlaceHolder'] =  'Cantidad de agua',
    ['DestroyWater'] = 'Ya no se puede usar mas esta botella',

    -- VORP METABOLSIM NOTIFY
    ['Hunger'] = 'Tienes mucha hambre',
    ['Thirst'] = 'Te estás deshidratando',
}

