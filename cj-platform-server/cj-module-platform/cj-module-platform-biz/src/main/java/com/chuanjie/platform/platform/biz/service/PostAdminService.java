package com.chuanjie.platform.platform.biz.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.chuanjie.platform.framework.error.BizException;
import com.chuanjie.platform.platform.biz.domain.PlatformPost;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.chuanjie.platform.platform.biz.mapper.PlatformPostMapper;
import com.chuanjie.platform.platform.biz.web.dto.PostSaveRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/** 岗位维护。 */
@Service
public class PostAdminService {

    private final PlatformPostMapper postMapper;

    public PostAdminService(PlatformPostMapper postMapper) {
        this.postMapper = postMapper;
    }

    public List<PlatformPost> listAll() {
        return postMapper.selectList(new LambdaQueryWrapper<PlatformPost>()
                .orderByAsc(PlatformPost::getSortNo)
                .orderByAsc(PlatformPost::getId));
    }

    public Long create(PostSaveRequest req, String operator) {
        PlatformPost post = new PlatformPost();
        post.setCode(req.getCode());
        post.setName(req.getName());
        post.setSortNo(req.getSortNo() == null ? 0 : req.getSortNo());
        post.setStatus("active");
        post.setCreator(operator);
        post.setCreateTime(LocalDateTime.now());
        post.setUpdater(operator);
        post.setUpdateTime(LocalDateTime.now());
        post.setDeleted(false);
        post.setVersion(0);
        postMapper.insert(post);
        return post.getId();
    }

    public void update(long id, PostSaveRequest req, String operator) {
        PlatformPost post = postMapper.selectById(id);
        if (post == null) {
            throw new BizException(PlatformErrorCodes.POST_NOT_FOUND, "岗位不存在");
        }
        post.setCode(req.getCode());
        post.setName(req.getName());
        if (req.getSortNo() != null) {
            post.setSortNo(req.getSortNo());
        }
        post.setUpdater(operator);
        post.setUpdateTime(LocalDateTime.now());
        postMapper.updateById(post);
    }
}
