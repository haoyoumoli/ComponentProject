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

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import "MatrixPlugin.h"

#import "WCReportStrategyDelegate.h"
#import "WCCrashBlockMonitorConfig.h"
#import "WCBlockTypeDef.h"

// Define the report type, use the report type to seperate the crash and lag
typedef NS_ENUM(NSUInteger, EMCrashBlockReportType) {
    EMCrashBlockReportType_Crash = 1,
    EMCrashBlockReportType_Lag = 2,
};

#define g_crash_block_monitor_custom_file_count "filecount"
#define g_crash_block_monitor_custom_dump_type "dumptype"
#define g_crash_block_monitor_custom_report_id "reportID"

@interface WCCrashBlockMonitorPlugin : MatrixPlugin

@property (nonatomic, strong) WCCrashBlockMonitorConfig *pluginConfig;

@property (nonatomic, weak) id<WCReportStrategyDelegate> reportDelegate;

// ============================================================================
#pragma mark - Utility
// ============================================================================

/// reset the version info in crash files and lag files
- (void)resetAppFullVersion:(NSString *)fullVersion shortVersion:(NSString *)shortVersion;

// ============================================================================
#pragma mark - Control of Block Monitor
// ============================================================================

- (void)startBlockMonitor;

- (void)stopBlockMonitor;

// ============================================================================
#pragma mark - CPU
// ============================================================================

// By default, the CPU tracking is open
// you can close the CPU tracking, when the app is definitely costing CPU resources.

// control the CPU tracking

- (void)startTrackCPU;
- (void)stopTrackCPU;

// get the CPU cost in background
- (BOOL)isBackgroundCPUTooSmall;

// ============================================================================
#pragma mark - Hangs Detection
// ============================================================================

// changes the threshold of runloop hangs detection. Requirements: [400ms, 2000ms], multiple of 100ms.
- (BOOL)setRunloopThreshold:(useconds_t)threshold;

// lowers the threshold to detect more runloop hangs.
- (BOOL)lowerRunloopThreshold;

// recovers the runloop threshold to the default value.
- (BOOL)recoverRunloopThreshold;

// whether to suspend all threads when saving dump
- (void)setShouldSuspendAllThreads:(BOOL)shouldSuspendAllThreads;

// ============================================================================
#pragma mark - Custom Dump
// ============================================================================

// generate a dump file immediately.
- (void)generateLiveReportWithDumpType:(EDumpType)dumpType withReason:(NSString *)reason selfDefinedPath:(BOOL)bSelfDefined;

@end
