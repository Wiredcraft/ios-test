package com.test.aric.presentation.user_detail

import android.annotation.SuppressLint
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Button
import androidx.compose.material.ButtonDefaults
import androidx.compose.material.Divider
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.test.aric.R
import androidx.constraintlayout.compose.ConstraintLayout
import androidx.constraintlayout.compose.Dimension
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.test.aric.data.remote.dto.UserInfo
import com.test.aric.presentation.search_user_list.SearchUserListViewModel
import com.test.aric.presentation.search_user_list.components.SearchUserListItem
import com.test.aric.presentation.user_detail.components.RepoInfoItem

@SuppressLint("SuspiciousIndentation")
@Composable
fun UserDetailScreen(
    viewModel: SearchUserListViewModel
) {
    val state = viewModel.selectedUserInfo



    ConstraintLayout(modifier = Modifier.fillMaxSize()) {
        val (bgHeader, ivAvatar, login, subscribe, indicator, repoListTitle, repoList) = createRefs()

        Image(
            painter = painterResource(id = R.drawable.bg_round),
            contentDescription = null,
            contentScale = ContentScale.FillBounds,

            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
                .constrainAs(bgHeader) {
                    top.linkTo(parent.top)
                    start.linkTo(parent.start)
                    end.linkTo(parent.end)
                }
        )

        AsyncImage(
            model = state.avatar_url,
            contentDescription = null,
            modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .constrainAs(ivAvatar) {
                    top.linkTo(bgHeader.top)
                    start.linkTo(bgHeader.start)
                    end.linkTo(bgHeader.end)
                    bottom.linkTo(login.top)
                }
        )


        Text(state.login,
            color = Color.White,
            modifier = Modifier.constrainAs(login) {
                top.linkTo(ivAvatar.bottom)
                start.linkTo(bgHeader.start)
                end.linkTo(bgHeader.end)
                bottom.linkTo(subscribe.top)
            }
        )


        Button(
            onClick = { },
            colors = ButtonDefaults.buttonColors(backgroundColor = Color.White),
            modifier = Modifier
                .padding(0.dp)
                .height(34.dp)
                .width(76.dp)
                .constrainAs(subscribe) {
                    top.linkTo(login.bottom)
                    start.linkTo(bgHeader.start)
                    end.linkTo(bgHeader.end)
                    bottom.linkTo(bgHeader.bottom)
                }
        ) {

            Text(
                text = if (state.follow) "关注" else "不关注",
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black
            )
        }


        Divider(modifier = Modifier
            .constrainAs(indicator) {
                top.linkTo(bgHeader.bottom)
                start.linkTo(parent.start)
            }
            .padding(top = 24.dp)
            .width(2.dp)
            .height(20.dp)
            .background(Color.Black))

        Text("REPOSITORIES", modifier = Modifier
            .padding(top = 24.dp, start = 10.dp)
            .constrainAs(repoListTitle) {
                top.linkTo(indicator.top)
                start.linkTo(indicator.end)
                bottom.linkTo(indicator.bottom)
            })

        LazyColumn(modifier = Modifier
            .constrainAs(repoList) {
                top.linkTo(indicator.bottom)
                start.linkTo(parent.start)
                bottom.linkTo(parent.bottom)
            }) {  items(viewModel.repoList.value.lists){
                RepoInfoItem(repoInfo = it)
        }
        }

    }
}