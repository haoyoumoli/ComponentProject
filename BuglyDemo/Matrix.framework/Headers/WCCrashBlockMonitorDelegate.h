/*
 * Tencent is pleased to support the open source community by making wechat-matrix available.
 * Copyright (C) 2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the BSD 3-Clause License (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef WCCrashBlockMonitorDelegate_h
#define WCCrashBlockMonitorDelegate_h

#import "WCBlockTypeDef.h"

@protocol WCCrashBlockMonitorDelegate <NSObject>

@optional

/// the BlockMonitor enters next round of checking
- (void)onCrashBlockMonitorEnterNextCheckWithDumpType:(EDumpType)dumpType;

/// begin to dump the lag file.
- (void)onCrashBlockMonitorBeginDump:(EDumpType)dumpType blockTime:(uint64_t)blockTime runloopThreshold:(useconds_t)runloopThreshold;

- (void)onCrashBlockMonitorBeginDump:(EDumpType)dumpType blockTime:(uint64_t)blockTime __deprecated_msg("use onCrashBlockMonitorBeginDump:blockTime:runloopThreshold: instead");

/// get a lag file
- (void)onCrashBlockMonitorGetDumpFile:(NSString *)dumpFile withDumpType:(EDumpType)dumpType;

/// detect a lag event, but have been filtered.
- (void)onCrashBlockMonitorDumpType:(EDumpType)dumpType filter:(EFilterType)filterType;

/// detect cpu too high
- (void)onCrashBlockMonitorCurrentCPUTooHigh;

/// detect power consume
- (void)onCrashBlockMonitorIntervalCPUTooHigh;

/// detect when the device gets hotter
- (void)onCrashBlockMonitorThermalStateElevated;

/// detect when the main thread hangs
- (void)onCrashBlockMonitorMainThreadBlock;

/// detect when using excessive memory
- (void)onCrashBlockMonitorMemoryExcessive;

/// get extra info for FrameDropDump file.
- (NSDictionary *)onCrashBlockMonitorGetCustomUserInfoForDumpType:(EDumpType)dumpType;

/// detect when the main thread hangs (sensitive)
- (void)onCrashBlockMonitorRunloopHangDetected:(uint64_t)duration;

@end

#endif /* WCCrashBlockMonitorDelegate_h */
