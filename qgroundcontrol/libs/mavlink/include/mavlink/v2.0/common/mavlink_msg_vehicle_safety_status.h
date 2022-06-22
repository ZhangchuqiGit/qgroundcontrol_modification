#pragma once
// MESSAGE VEHICLE_SAFETY_STATUS PACKING

#include <cstdint>
#include <cstdlib>

#define MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS 236


typedef struct __mavlink_vehicle_safety_status_t {
 uint64_t time_usec; /*< [us]
				Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
			*/
 float motor_current[16]; /*< [A] 
				The Current of earch motor
			*/
 float motor_temperature[16]; /*< [cdegC] 
				The temperature of earch motor
			*/
 float motor_speed[16]; /*< [rad/min] 
				The speed of earch motor
			*/
 float battery_voltage; /*< [V] 
				Battery voltage of cells. Cells above the valid cell count for this battery should have the UINT16_MAX value
			*/
} mavlink_vehicle_safety_status_t;

#define MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN 204
#define MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN 204
#define MAVLINK_MSG_ID_236_LEN 204
#define MAVLINK_MSG_ID_236_MIN_LEN 204

#define MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC 243
#define MAVLINK_MSG_ID_236_CRC 243

#define MAVLINK_MSG_VEHICLE_SAFETY_STATUS_FIELD_MOTOR_CURRENT_LEN 16
#define MAVLINK_MSG_VEHICLE_SAFETY_STATUS_FIELD_MOTOR_TEMPERATURE_LEN 16
#define MAVLINK_MSG_VEHICLE_SAFETY_STATUS_FIELD_MOTOR_SPEED_LEN 16

#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_VEHICLE_SAFETY_STATUS { \
    236, \
    "VEHICLE_SAFETY_STATUS", \
    5, \
    {  { "time_usec", NULL, MAVLINK_TYPE_UINT64_T, 0, 0, offsetof(mavlink_vehicle_safety_status_t, time_usec) }, \
         { "motor_current", NULL, MAVLINK_TYPE_FLOAT, 16, 8, offsetof(mavlink_vehicle_safety_status_t, motor_current) }, \
         { "motor_temperature", NULL, MAVLINK_TYPE_FLOAT, 16, 72, offsetof(mavlink_vehicle_safety_status_t, motor_temperature) }, \
         { "motor_speed", NULL, MAVLINK_TYPE_FLOAT, 16, 136, offsetof(mavlink_vehicle_safety_status_t, motor_speed) }, \
         { "battery_voltage", NULL, MAVLINK_TYPE_FLOAT, 0, 200, offsetof(mavlink_vehicle_safety_status_t, battery_voltage) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_VEHICLE_SAFETY_STATUS { \
    "VEHICLE_SAFETY_STATUS", \
    5, \
    {  { "time_usec", NULL, MAVLINK_TYPE_UINT64_T, 0, 0, offsetof(mavlink_vehicle_safety_status_t, time_usec) }, \
         { "motor_current", NULL, MAVLINK_TYPE_FLOAT, 16, 8, offsetof(mavlink_vehicle_safety_status_t, motor_current) }, \
         { "motor_temperature", NULL, MAVLINK_TYPE_FLOAT, 16, 72, offsetof(mavlink_vehicle_safety_status_t, motor_temperature) }, \
         { "motor_speed", NULL, MAVLINK_TYPE_FLOAT, 16, 136, offsetof(mavlink_vehicle_safety_status_t, motor_speed) }, \
         { "battery_voltage", NULL, MAVLINK_TYPE_FLOAT, 0, 200, offsetof(mavlink_vehicle_safety_status_t, battery_voltage) }, \
         } \
}
#endif

/**
 * @brief Pack a vehicle_safety_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param time_usec [us] 
				Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
			
 * @param motor_current [A] 
				The Current of earch motor
			
 * @param motor_temperature [cdegC] 
				The temperature of earch motor
			
 * @param motor_speed [rad/min] 
				The speed of earch motor
			
 * @param battery_voltage [V] 
				Battery voltage of cells. Cells above the valid cell count for this battery should have the UINT16_MAX value
			
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint64_t time_usec, const float *motor_current, const float *motor_temperature, const float *motor_speed, float battery_voltage)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN];
    _mav_put_uint64_t(buf, 0, time_usec);
    _mav_put_float(buf, 200, battery_voltage);
    _mav_put_float_array(buf, 8, motor_current, 16);
    _mav_put_float_array(buf, 72, motor_temperature, 16);
    _mav_put_float_array(buf, 136, motor_speed, 16);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN);
#else
    mavlink_vehicle_safety_status_t packet;
    packet.time_usec = time_usec;
    packet.battery_voltage = battery_voltage;
    mav_array_memcpy(packet.motor_current, motor_current, sizeof(float)*16);
    mav_array_memcpy(packet.motor_temperature, motor_temperature, sizeof(float)*16);
    mav_array_memcpy(packet.motor_speed, motor_speed, sizeof(float)*16);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
}

/**
 * @brief Pack a vehicle_safety_status message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param time_usec [us] 
				Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
			
 * @param motor_current [A] 
				The Current of earch motor
			
 * @param motor_temperature [cdegC] 
				The temperature of earch motor
			
 * @param motor_speed [rad/min] 
				The speed of earch motor
			
 * @param battery_voltage [V] 
				Battery voltage of cells. Cells above the valid cell count for this battery should have the UINT16_MAX value
			
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint64_t time_usec,const float *motor_current,const float *motor_temperature,const float *motor_speed,float battery_voltage)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN];
    _mav_put_uint64_t(buf, 0, time_usec);
    _mav_put_float(buf, 200, battery_voltage);
    _mav_put_float_array(buf, 8, motor_current, 16);
    _mav_put_float_array(buf, 72, motor_temperature, 16);
    _mav_put_float_array(buf, 136, motor_speed, 16);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN);
#else
    mavlink_vehicle_safety_status_t packet;
    packet.time_usec = time_usec;
    packet.battery_voltage = battery_voltage;
    mav_array_memcpy(packet.motor_current, motor_current, sizeof(float)*16);
    mav_array_memcpy(packet.motor_temperature, motor_temperature, sizeof(float)*16);
    mav_array_memcpy(packet.motor_speed, motor_speed, sizeof(float)*16);
        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
}

/**
 * @brief Encode a vehicle_safety_status struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param vehicle_safety_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_vehicle_safety_status_t* vehicle_safety_status)
{
    return mavlink_msg_vehicle_safety_status_pack(system_id, component_id, msg, vehicle_safety_status->time_usec, vehicle_safety_status->motor_current, vehicle_safety_status->motor_temperature, vehicle_safety_status->motor_speed, vehicle_safety_status->battery_voltage);
}

/**
 * @brief Encode a vehicle_safety_status struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param vehicle_safety_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_vehicle_safety_status_t* vehicle_safety_status)
{
    return mavlink_msg_vehicle_safety_status_pack_chan(system_id, component_id, chan, msg, vehicle_safety_status->time_usec, vehicle_safety_status->motor_current, vehicle_safety_status->motor_temperature, vehicle_safety_status->motor_speed, vehicle_safety_status->battery_voltage);
}

/**
 * @brief Send a vehicle_safety_status message
 * @param chan MAVLink channel to send the message
 *
 * @param time_usec [us] 
				Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
			
 * @param motor_current [A] 
				The Current of earch motor
			
 * @param motor_temperature [cdegC] 
				The temperature of earch motor
			
 * @param motor_speed [rad/min] 
				The speed of earch motor
			
 * @param battery_voltage [V] 
				Battery voltage of cells. Cells above the valid cell count for this battery should have the UINT16_MAX value
			
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_vehicle_safety_status_send(mavlink_channel_t chan, uint64_t time_usec, const float *motor_current, const float *motor_temperature, const float *motor_speed, float battery_voltage)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN];
    _mav_put_uint64_t(buf, 0, time_usec);
    _mav_put_float(buf, 200, battery_voltage);
    _mav_put_float_array(buf, 8, motor_current, 16);
    _mav_put_float_array(buf, 72, motor_temperature, 16);
    _mav_put_float_array(buf, 136, motor_speed, 16);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS, buf, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
#else
    mavlink_vehicle_safety_status_t packet;
    packet.time_usec = time_usec;
    packet.battery_voltage = battery_voltage;
    mav_array_memcpy(packet.motor_current, motor_current, sizeof(float)*16);
    mav_array_memcpy(packet.motor_temperature, motor_temperature, sizeof(float)*16);
    mav_array_memcpy(packet.motor_speed, motor_speed, sizeof(float)*16);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS, (const char *)&packet, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
#endif
}

/**
 * @brief Send a vehicle_safety_status message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_vehicle_safety_status_send_struct(mavlink_channel_t chan, const mavlink_vehicle_safety_status_t* vehicle_safety_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_vehicle_safety_status_send(chan, vehicle_safety_status->time_usec, vehicle_safety_status->motor_current, vehicle_safety_status->motor_temperature, vehicle_safety_status->motor_speed, vehicle_safety_status->battery_voltage);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS, (const char *)vehicle_safety_status, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
#endif
}

#if MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by re-using
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_vehicle_safety_status_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint64_t time_usec, const float *motor_current, const float *motor_temperature, const float *motor_speed, float battery_voltage)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint64_t(buf, 0, time_usec);
    _mav_put_float(buf, 200, battery_voltage);
    _mav_put_float_array(buf, 8, motor_current, 16);
    _mav_put_float_array(buf, 72, motor_temperature, 16);
    _mav_put_float_array(buf, 136, motor_speed, 16);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS, buf, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
#else
    mavlink_vehicle_safety_status_t *packet = (mavlink_vehicle_safety_status_t *)msgbuf;
    packet->time_usec = time_usec;
    packet->battery_voltage = battery_voltage;
    mav_array_memcpy(packet->motor_current, motor_current, sizeof(float)*16);
    mav_array_memcpy(packet->motor_temperature, motor_temperature, sizeof(float)*16);
    mav_array_memcpy(packet->motor_speed, motor_speed, sizeof(float)*16);
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS, (const char *)packet, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_MIN_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_CRC);
#endif
}
#endif

#endif

// MESSAGE VEHICLE_SAFETY_STATUS UNPACKING


/**
 * @brief Get field time_usec from vehicle_safety_status message
 *
 * @return [us] 
				Timestamp (UNIX Epoch time or time since system boot). The receiving end can infer timestamp format (since 1.1.1970 or since system boot) by checking for the magnitude the number.
			
 */
static inline uint64_t mavlink_msg_vehicle_safety_status_get_time_usec(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint64_t(msg,  0);
}

/**
 * @brief Get field motor_current from vehicle_safety_status message
 *
 * @return [A] 
				The Current of earch motor
			
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_get_motor_current(const mavlink_message_t* msg, float *motor_current)
{
    return _MAV_RETURN_float_array(msg, motor_current, 16,  8);
}

/**
 * @brief Get field motor_temperature from vehicle_safety_status message
 *
 * @return [cdegC] 
				The temperature of earch motor
			
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_get_motor_temperature(const mavlink_message_t* msg, float *motor_temperature)
{
    return _MAV_RETURN_float_array(msg, motor_temperature, 16,  72);
}

/**
 * @brief Get field motor_speed from vehicle_safety_status message
 *
 * @return [rad/min] 
				The speed of earch motor
			
 */
static inline uint16_t mavlink_msg_vehicle_safety_status_get_motor_speed(const mavlink_message_t* msg, float *motor_speed)
{
    return _MAV_RETURN_float_array(msg, motor_speed, 16,  136);
}

/**
 * @brief Get field battery_voltage from vehicle_safety_status message
 *
 * @return [V] 
				Battery voltage of cells. Cells above the valid cell count for this battery should have the UINT16_MAX value
			
 */
static inline float mavlink_msg_vehicle_safety_status_get_battery_voltage(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  200);
}

/**
 * @brief Decode a vehicle_safety_status message into a struct
 *
 * @param msg The message to decode
 * @param vehicle_safety_status C-struct to decode the message contents into
 */
static inline void mavlink_msg_vehicle_safety_status_decode(const mavlink_message_t* msg, mavlink_vehicle_safety_status_t* vehicle_safety_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    vehicle_safety_status->time_usec = mavlink_msg_vehicle_safety_status_get_time_usec(msg);
    mavlink_msg_vehicle_safety_status_get_motor_current(msg, vehicle_safety_status->motor_current);
    mavlink_msg_vehicle_safety_status_get_motor_temperature(msg, vehicle_safety_status->motor_temperature);
    mavlink_msg_vehicle_safety_status_get_motor_speed(msg, vehicle_safety_status->motor_speed);
    vehicle_safety_status->battery_voltage = mavlink_msg_vehicle_safety_status_get_battery_voltage(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN? msg->len : MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN;
        memset(vehicle_safety_status, 0, MAVLINK_MSG_ID_VEHICLE_SAFETY_STATUS_LEN);
    memcpy(vehicle_safety_status, _MAV_PAYLOAD(msg), len);
#endif
}
