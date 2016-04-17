-- our constants
red = 8
blue = 7
green = 6
sensor_pin = 0

-- blinking status
function blink(led_pin, delay_ms)
    gpio.mode(6, gpio.OUTPUT)
    gpio.mode(7, gpio.OUTPUT)
    gpio.mode(8, gpio.OUTPUT)
    gpio.write(6, gpio.LOW)
    gpio.write(7, gpio.LOW)
    gpio.write(8, gpio.LOW)
    gpio.write(led_pin, gpio.HIGH)
    tmr.delay(delay_ms)
    gpio.write(led_pin, gpio.LOW)
end

-- post sensor data to our server
function send_sensor_data()
    -- our constants
    sensor_name = "witty-01"
    data = adc.read(sensor_pin)
    command = "POST /entries"
    host = "172.29.5.202"
    content_type = "application/x-www-form-urlencoded"
    content = "entry[data]="..data.."&entry[sensor_name]="..sensor_name
    --test packet
    -- (we want our request to look as much like this as possible)
    packet = 
    "POST /entries HTTP/1.1\r\n"..
    "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)\r\n"..
    "Host: 172.29.5.202\r\n"..
    "Accept: */*\r\n"..
    "Content-Length: 38\r\n"..
    "Content-Type: application/x-www-form-urlencoded\r\n\r\n"..
    "entry[data]=17&entry[sensor_name]=test"
    
    -- protocol
    conn=net.createConnection(net.TCP, 0)
    conn:on("connection",function(conn, payload)
        print("Sending "..content.." to "..host)
        -- header
        --  (be VERY careful about which lines get \r\n and don't double!)
        header = command.." HTTP/1.1\r\n".. 
                  "Host: "..host.."\r\n"..
                  "Accept: */*\r\n"..
                  "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                  "\r\n"
        print("Header: "..header)
        conn:send(header)
        -- content info
        conn:send("Content-Type: " .. content_type .. "\r\n")
        conn:send("Content-Length: " .. string.len(content) .. "\r\n\r\n")
        -- actual content
        conn:send(content)
    end)
    conn:on("receive",function(conn, payload)
        status = string.match(payload, "HTTP/%d.%d (%d+)")
        print("Status: "..status)
        print("Received payload "..payload)
        if status == "201" then -- created successfully
            blink(green, 100)
        else
            blink(red, 100)
        end
        collectgarbage() -- for safety, maybe?
        conn:close()
    end)
    conn:connect(80, host)
end

num_iter = 1
-- timer
tmr.alarm(0, 10000, 1, function()
    print("Timer iteration "..num_iter)
    num_iter = num_iter + 1
    blink(blue, 100) -- signal for start transfer
    send_sensor_data()
end)