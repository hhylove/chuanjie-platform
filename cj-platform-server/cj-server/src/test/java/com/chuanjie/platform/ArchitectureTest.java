package com.chuanjie.platform;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

/**
 * 守住业务模块边界，避免模块化单体退化为跨包直接依赖。
 */
@AnalyzeClasses(packages = "com.chuanjie.platform", importOptions = ImportOption.DoNotIncludeTests.class)
class ArchitectureTest {

    @ArchTest
    static final ArchRule MODULES_MUST_NOT_FORM_CYCLES = slices()
            .matching("com.chuanjie.platform.(*)..")
            .should().beFreeOfCycles();
}
