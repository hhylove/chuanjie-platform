import { createRouter, createWebHistory } from 'vue-router'
import { isLoggedIn } from '@cj/auth'
import AdminLayout from '../layouts/AdminLayout.vue'
import LoginPage from '../pages/LoginPage.vue'
import HomePage from '../pages/HomePage.vue'
import UsersPage from '../pages/system/UsersPage.vue'
import DeptsPage from '../pages/system/DeptsPage.vue'
import RolesPage from '../pages/system/RolesPage.vue'

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginPage,
      meta: { public: true },
    },
    {
      path: '/',
      component: AdminLayout,
      children: [
        {
          path: '',
          name: 'home',
          component: HomePage,
          meta: { title: '工作台' },
        },
        {
          path: 'system/users',
          name: 'users',
          component: UsersPage,
          meta: { title: '用户管理', groupKey: 'org', groupTitle: '组织管理' },
        },
        {
          path: 'system/depts',
          name: 'depts',
          component: DeptsPage,
          meta: { title: '部门管理', groupKey: 'org', groupTitle: '组织管理' },
        },
        {
          path: 'system/roles',
          name: 'roles',
          component: RolesPage,
          meta: { title: '角色管理', groupKey: 'org', groupTitle: '组织管理' },
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  if (to.meta.public) {
    if (isLoggedIn() && to.name === 'login') {
      return { name: 'home' }
    }
    return true
  }
  if (!isLoggedIn()) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  return true
})
