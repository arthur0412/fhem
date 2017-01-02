//###################################################################################
//#################################### Plugin 130: _P130_SSSRV ############################################
//################################ software serial server #########################################
//####################################### by amunra v0.1 ################################################
//#######################################################################################################

#include <SoftwareSerial.h>
#define PLUGIN_130
#define PLUGIN_ID_130         130
#define PLUGIN_NAME_130       "Software Serial Server"
#define PLUGIN_VALUENAME1_130 "SwSerSrv"
 
#define BUFFER_SIZE_SW 128
boolean Plugin_130_init = false;
 
WiFiServer *ser2netServerSW;
WiFiClient ser2netClientSW;
//SoftwareSerial swSer(14, 12, false, 256); DEVKIT 1.0 for test...
// recive 14 --> D5 e transmit 12 --> D6 e invert e buffersize  
SoftwareSerial swSer(13, 15, false, 256); // Wemos D1 Mini
// recive 14 --> D5 e transmit 12 --> D6 e invert e buffersize 


boolean Plugin_130(byte function, struct EventStruct *event, String& string)
{
  boolean success = false;

  switch (function) 
  {

    case PLUGIN_DEVICE_ADD:
      {
        Device[++deviceCount].Number = PLUGIN_ID_130;
        Device[deviceCount].Type = DEVICE_TYPE_SINGLE;
        Device[deviceCount].VType = SENSOR_TYPE_SINGLE;
        Device[deviceCount].Custom = true;
        Device[deviceCount].TimerOption = false;
        break;
      }

    case PLUGIN_GET_DEVICENAME:
      {
        string = F(PLUGIN_NAME_130);
        break;
      }

    case PLUGIN_GET_DEVICEVALUENAMES:
      {
        strcpy_P(ExtraTaskSettings.TaskDeviceValueNames[0], PSTR(PLUGIN_VALUENAME1_130));
        break;
      }

    case PLUGIN_WEBFORM_LOAD:
      {
        char tmpString[128];
        sprintf_P(tmpString, PSTR("<TR><TD>TCP Port:<TD><input type='text' name='plugin_130_port' value='%u'>"), ExtraTaskSettings.TaskDevicePluginConfigLong[0]);
        string += tmpString;
        sprintf_P(tmpString, PSTR("<TR><TD>Baud Rate:<TD><input type='text' name='plugin_130_baud' value='%u'>"), ExtraTaskSettings.TaskDevicePluginConfigLong[1]);
        string += tmpString;

       
        string += F("<TR><TD>Select pin, not used now:<TD>");
        addPinSelect(false, string, "taskdevicepin1", Settings.TaskDevicePin1[event->TaskIndex]);

        
        success = true;
        break;
      }

    case PLUGIN_WEBFORM_SAVE:
      {
        String plugin1 = WebServer.arg("plugin_130_port");
        ExtraTaskSettings.TaskDevicePluginConfigLong[0] = plugin1.toInt();
        String plugin2 = WebServer.arg("plugin_130_baud");
        ExtraTaskSettings.TaskDevicePluginConfigLong[1] = plugin2.toInt();
        SaveTaskSettings(event->TaskIndex);
        success = true;
        break;
      }

    case PLUGIN_INIT:
      {
        LoadTaskSettings(event->TaskIndex);
        int irPin = Settings.TaskDevicePin1[event->TaskIndex];
        irPin =14;
        if ((ExtraTaskSettings.TaskDevicePluginConfigLong[0] != 0) && (ExtraTaskSettings.TaskDevicePluginConfigLong[1] != 0) && (irPin != -1))
        {
          swSer.begin(ExtraTaskSettings.TaskDevicePluginConfigLong[1]);
          
          ser2netServerSW = new WiFiServer(ExtraTaskSettings.TaskDevicePluginConfigLong[0]);
          ser2netServerSW->begin();
          //String tmp =String((ExtraTaskSettings.TaskDevicePluginConfigLong[1]),DEC);
          //addLog(2,tmp);
          Plugin_130_init = true;
        }
        success = true;
        break;
      }

    case PLUGIN_TEN_PER_SECOND:
      {
        if (Plugin_130_init)
        {
          size_t bytes_read;
          if (!ser2netClientSW)
          {
            while (swSer.available()) {
              swSer.read();
            }
            ser2netClientSW = ser2netServerSW->available();
          }

          if (ser2netClientSW.connected())
          {
            uint8_t net_buf[BUFFER_SIZE_SW];
            int count = ser2netClientSW.available();
            if (count > 0) {
              if (count > BUFFER_SIZE_SW)
                count = BUFFER_SIZE_SW;
              bytes_read = ser2netClientSW.read(net_buf, count);
              swSer.write(net_buf, bytes_read);
              //swSer.flush();
              net_buf[count]=0;
              //addLog(LOG_LEVEL_DEBUG,(char*)net_buf);
            }
            uint8_t serial_buf[BUFFER_SIZE_SW];
            size_t bytes_read = 0;
            while (swSer.available() && bytes_read < BUFFER_SIZE_SW) {
              serial_buf[bytes_read] = swSer.read();
              bytes_read++;
            }
            if (bytes_read > 0) {
              ser2netClientSW.write((const uint8_t*)serial_buf, bytes_read);
              ser2netClientSW.flush();
            }
            serial_buf[bytes_read]=0;
            //addLog(LOG_LEVEL_DEBUG,(char*)serial_buf);
          }
          else 
          {
            ser2netClientSW.stop();
            swSer.flush();
          }
          success = true;
        }
        break;
      }

  }
  return success;
}
